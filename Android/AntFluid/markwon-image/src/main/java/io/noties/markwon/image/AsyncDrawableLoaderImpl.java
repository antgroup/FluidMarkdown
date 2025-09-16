package io.noties.markwon.image;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;

import com.fluid.afm.utils.Utils;

class AsyncDrawableLoaderImpl extends AsyncDrawableLoader {

    public static final String TAG = "MD_AsyncDrawLoaderImpl";
    private final ExecutorService executorService;
    private final Map<String, SchemeHandler> schemeHandlers;
    private final Map<String, MediaDecoder> mediaDecoders;
    private final MediaDecoder defaultMediaDecoder;
    private final ImagesPlugin.PlaceholderProvider placeholderProvider;
    private final ImagesPlugin.ErrorHandler errorHandler;

    private final Handler handler;

    // @since 4.0.0 use a hash-map with a AsyncDrawable as key for multiple requests
    //  for the same destination
    private final Map<AsyncDrawable, Future<?>> requests = new HashMap<>(2);

    AsyncDrawableLoaderImpl(@NonNull AsyncDrawableLoaderBuilder builder) {
        this(builder, new Handler(Looper.getMainLooper()));
        Log.d(TAG, "AsyncDrawableLoaderImpl construct");
    }

    // @since 4.0.0
    @VisibleForTesting
    AsyncDrawableLoaderImpl(@NonNull AsyncDrawableLoaderBuilder builder, @NonNull Handler handler) {
        this.executorService = builder.executorService;
        this.schemeHandlers = builder.schemeHandlers;
        this.mediaDecoders = builder.mediaDecoders;
        this.defaultMediaDecoder = builder.defaultMediaDecoder;
        this.placeholderProvider = builder.placeholderProvider;
        this.errorHandler = builder.errorHandler;
        this.handler = handler;
    }

    @Override
    public void load(@NonNull final AsyncDrawable drawable) {
        Log.d(TAG, "load drawable = " + drawable);
        final Future<?> future = requests.get(drawable);
        if (future == null) {
            requests.put(drawable, execute(drawable));
        }
    }

    @Override
    public void cancel(@NonNull final AsyncDrawable drawable) {

        Log.d(TAG, "cancel future");
        final Future<?> future = requests.remove(drawable);
        if (future != null) {
            future.cancel(true);
        }

        handler.removeCallbacksAndMessages(drawable);
    }

    @Nullable
    @Override
    public Drawable placeholder(@NonNull AsyncDrawable drawable) {
        return placeholderProvider != null
                ? placeholderProvider.providePlaceholder(drawable)
                : null;
    }

    public Bitmap drawableToBitmap(Drawable drawable) {
        if (drawable instanceof BitmapDrawable) {
            return ((BitmapDrawable) drawable).getBitmap();
        }

        int width = drawable.getIntrinsicWidth();
        int height = drawable.getIntrinsicHeight();
        Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);

        Canvas canvas = new Canvas(bitmap);
        drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
        drawable.draw(canvas);

        return bitmap;
    }

    @NonNull
    private Future<?> execute(@NonNull final AsyncDrawable asyncDrawable) {
        Log.d(TAG, "execute");
        return executorService.submit(() -> {
            String destination = asyncDrawable.getDestination();
            Log.d(TAG, "run destination = " + destination);
            final Uri uri = Uri.parse(destination);

            Drawable drawable = null;
            int canvasWidth = asyncDrawable.getLastKnownCanvasWidth();
            if (canvasWidth == 0) {
                canvasWidth = Utils.getScreenWidth();
            }
            int designedWidth = 638;
            int designedHeight = 360;
            float dpRatio = (float) canvasWidth / designedWidth;
            int standardHeight = (int) (designedHeight * dpRatio);
            try {
                final String scheme = uri.getScheme();
                if (TextUtils.isEmpty(scheme)) {
                    throw new IllegalStateException("No scheme is found: " + destination);
                }

                // obtain scheme handler
                final SchemeHandler schemeHandler = schemeHandlers.get(scheme);
                if (schemeHandler != null) {

                    Log.d(TAG, "schemeHandler.handle start ");
                    // handle scheme
                    final ImageItem imageItem = schemeHandler.handle(destination, uri, canvasWidth, standardHeight);

                    Log.d(TAG, "schemeHandler.handle finish ");
                    // if resulting imageItem needs further decoding -> proceed
                    if (imageItem.hasDecodingNeeded()) {

                        final ImageItem.WithDecodingNeeded withDecodingNeeded = imageItem.getAsWithDecodingNeeded();

                        // @since 4.6.2 close input stream
                        try {
                            MediaDecoder mediaDecoder = mediaDecoders.get(withDecodingNeeded.contentType());
                            Log.d(TAG, "mediaDecoder = " + mediaDecoder + " withDecodingNeeded.contentType() = " + withDecodingNeeded.contentType());

                            if (mediaDecoder == null) {
                                mediaDecoder = defaultMediaDecoder;
                            }

                            if (mediaDecoder != null) {
                                drawable = mediaDecoder.decode(withDecodingNeeded.contentType(), withDecodingNeeded.inputStream());
                            } else {
                                // throw that no media decoder is found
                                throw new IllegalStateException("No media-decoder is found: " + destination);
                            }
                        } finally {
                            try {
                                withDecodingNeeded.inputStream().close();
                            } catch (IOException e) {
                                Log.e("MARKWON-IMAGE", "Error closing inputStream", e);
                            }
                        }
                    } else {
                        Log.d(TAG, "getAsWithResult result");
                        drawable = imageItem.getAsWithResult().result();
                    }
                } else {
                    // throw no scheme handler is available
                    throw new IllegalStateException("No scheme-handler is found: " + destination);
                }

            } catch (Throwable t) {
                if (errorHandler != null) {
                    drawable = errorHandler.handleError(destination, t);
                } else {
                    // else simply log the error
                    Log.e("MARKWON-IMAGE", "Error loading image: " + destination, t);
                }
            }

            Log.d(TAG, "asyncDrawable.getLastKnownCanvasWidth() = " + asyncDrawable.getLastKnownCanvasWidth());

            int designedMinWidthForHeightOverWidth = 270;
            int rawWidth = drawable.getIntrinsicWidth();
            int rawHeight = drawable.getIntrinsicHeight();
            int minWidthForHeightOverWidth = (int) ((designedMinWidthForHeightOverWidth / 2) * dpRatio);
            Bitmap bitmap = drawableToBitmap(drawable);
            Bitmap corpedBgBitmap = scaleAndCropCenter(bitmap, canvasWidth, standardHeight);
            if (rawWidth < rawHeight) {
                Bitmap transparentBitmap = setBitmapTransparency(corpedBgBitmap, 128);
                Bitmap fgBitmap = scaleAndCropHeightOverWidthBitmap(bitmap, standardHeight, minWidthForHeightOverWidth);
                Bitmap combineBitmap = overlayBitmaps(transparentBitmap, fgBitmap);
                Bitmap output = getRoundedCornerBitmap(combineBitmap, 24);
                drawable = new BitmapDrawable(null, output);
            } else {
                Bitmap output = getRoundedCornerBitmap(corpedBgBitmap, 24);
                drawable = new BitmapDrawable(null, output);
            }

            final Drawable out = drawable;

            // @since 4.0.0 apply intrinsic bounds (but only if they are empty)
            if (out != null) {
                final Rect bounds = out.getBounds();
                //noinspection ConstantConditions
                if (bounds == null
                        || bounds.isEmpty()) {
                    DrawableUtils.applyIntrinsicBounds(out);
                }
            }

            Log.d(TAG, "SystemClock.uptimeMillis() = " + SystemClock.uptimeMillis());
            handler.postAtTime(new Runnable() {
                @Override
                public void run() {
                    Log.d(TAG, "postAtTime asyncDrawable Destination = " + asyncDrawable.getDestination());
                    // validate that
                    // * request was not cancelled
                    // * out-result is present
                    // * async-drawable is attached
                    final Future<?> future = requests.remove(asyncDrawable);
                    Log.d(TAG, "future = " + future + " out = " + out + " asyncDrawable.isAttached() =" + asyncDrawable.isAttached());

                    if (future != null
                            && out != null
                            && asyncDrawable.isAttached()) {
                        Log.d(TAG, "asyncDrawable.setResult(out)");
                        asyncDrawable.setResult(out);
                    }
                }
            }, asyncDrawable, SystemClock.uptimeMillis());
        });
    }

    public Bitmap setBitmapTransparency(Bitmap bitmap, int alpha) {
        Bitmap transparentBitmap = Bitmap.createBitmap(bitmap.getWidth(), bitmap.getHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(transparentBitmap);
        Paint paint = new Paint();
        paint.setAlpha(alpha);
        canvas.drawBitmap(bitmap, 0, 0, paint);
        return transparentBitmap;
    }

    public Bitmap overlayBitmaps(Bitmap background, Bitmap overlay) {
        Bitmap overlayBitmap = Bitmap.createBitmap(background.getWidth(), background.getHeight(), background.getConfig());
        Canvas canvas = new Canvas(overlayBitmap);
        canvas.drawBitmap(background, 0, 0, null);

        // 计算叠加图片的左上角坐标，使其居中
        int left = (background.getWidth() - overlay.getWidth()) / 2;
        int top = (background.getHeight() - overlay.getHeight()) / 2;

        // 绘制叠加图片
        canvas.drawBitmap(overlay, left, top, null);
        return overlayBitmap;
    }

    public Bitmap scaleAndCropCenter(Bitmap srcBitmap, int targetWidth, int targetHeight) {
        if (srcBitmap == null) return null;

        // 计算宽高比例
        float srcWidth = srcBitmap.getWidth();
        float srcHeight = srcBitmap.getHeight();

        float widthRatio = targetWidth / srcWidth;
        float heightRatio = targetHeight / srcHeight;

        // 选择较大的缩放比例
        float scale = Math.max(widthRatio, heightRatio);

        // 计算缩放后的宽高
        int scaledWidth = Math.round(srcWidth * scale);
        int scaledHeight = Math.round(srcHeight * scale);

        // 缩放图片
        Bitmap scaledBitmap = Bitmap.createScaledBitmap(srcBitmap, scaledWidth, scaledHeight, true);

        // 计算图片居中裁剪的起始点
        int xOffset = (scaledWidth - targetWidth) / 2;
        int yOffset = (scaledHeight - targetHeight) / 2;

        // 裁剪出目标区域
        Bitmap croppedBitmap = Bitmap.createBitmap(scaledBitmap, xOffset, yOffset, targetWidth, targetHeight);

        // 如果缩放图片与原图不同，则回收中间产生的 Bitmap
        if (scaledBitmap != srcBitmap) {
            scaledBitmap.recycle();
        }

        return croppedBitmap;
    }

    public Bitmap scaleAndCropHeightOverWidthBitmap(Bitmap bitmap, int fixedHeight, int minWidth) {
        int imgWidth = bitmap.getWidth();
        int imgHeight = bitmap.getHeight();

        // 计算缩放比例
        float scale = Math.max((float) fixedHeight / imgHeight, (float) minWidth / imgWidth);

        // 新的宽高
        int newWidth = Math.round(imgWidth * scale);
        int newHeight = Math.round(imgHeight * scale);

        // 缩放图片
        Bitmap scaledBitmap = Bitmap.createScaledBitmap(bitmap, newWidth, newHeight, true);

        // 居中裁剪图片
        int xCrop = (newWidth - minWidth) / 2;
        int yCrop = (newHeight - fixedHeight) / 2;

        return Bitmap.createBitmap(scaledBitmap, xCrop, yCrop, minWidth, fixedHeight);
    }

    public Bitmap getRoundedCornerBitmap(Bitmap bitmap, int cornerRadius) {
        // 保持原始位图大小
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();

        // 创建一个输出Bitmap
        Bitmap output = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        // 创建一个画布，这样我们就可以在其上绘制形状
        Canvas canvas = new Canvas(output);
        // 设置抗锯齿
        final Paint paint = new Paint();
        paint.setAntiAlias(true);
        paint.setFilterBitmap(true);
        paint.setDither(true);

        // 绘制一个圆角矩形作为底层
        Rect rect = new Rect(0, 0, width, height);
        RectF rectF = new RectF(rect);

        // 填充圆角矩形并剪裁画布
        paint.setColor(Color.BLACK);
        canvas.drawRoundRect(rectF, cornerRadius, cornerRadius, paint);

        // 使用 "SRC_IN" 模式，绘制原始位图到画布上，这样只会显示在圆角区域的部分
        paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));
        canvas.drawBitmap(bitmap, rect, rect, paint);

        return output;
    }

}
