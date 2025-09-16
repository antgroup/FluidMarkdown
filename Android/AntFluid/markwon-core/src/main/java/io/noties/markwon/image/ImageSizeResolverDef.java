package io.noties.markwon.image;

import android.content.Context;
import android.graphics.Rect;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * @since 1.0.1
 */
@SuppressWarnings({"WeakerAccess", "unused"})
public class ImageSizeResolverDef extends ImageSizeResolver {

    public static final String TAG = "MD_ImageSizeResolverDef";

    // we track these two, others are considered to be pixels
    protected static final String UNIT_PERCENT = "%";
    protected static final String UNIT_EM = "em";
    public static final String UNIT_RPX = "rpx";
    public static final String UNIT_PX = "px";

    @NonNull
    @Override
    public Rect resolveImageSize(@NonNull AsyncDrawable drawable) {
        Log.d(TAG,"resolveImageSize ");
        return resolveImageSize(drawable,
                drawable.getImageSize(),
                drawable.getResult().getBounds(),
                drawable.getLastKnownCanvasWidth(),
                drawable.getLastKnowTextSize());
    }

    @NonNull
    protected Rect resolveImageSize(
            @NonNull AsyncDrawable drawable,
            @Nullable ImageSize imageSize,
            @NonNull Rect imageBounds,
            int canvasWidth,
            float textSize
    ) {

        if (imageSize == null) {
            // @since 2.0.0 post process bounds to fit canvasWidth (previously was inside AsyncDrawable)
            //      must be applied only if imageSize is null
            final Rect rect;
            int w = imageBounds.width();
            int h = imageBounds.height();
            int designedWidth = 638;
            int designedHeight = 360;
            float dpRatio = ((float)canvasWidth * 2)/designedWidth;
            if((h < w)  && (canvasWidth > 0)) {
                float widthRatio = ((float) canvasWidth)/w;
                w = canvasWidth;
                h = (int)(widthRatio*h);
                int standardHeight = (int) ((designedHeight/2)*dpRatio);
                if(h>standardHeight){
                    h = standardHeight;
                }
            }else if((w <= h) && (canvasWidth > 0)){
                h = (int) ((designedHeight / 2 ) * dpRatio);
                w = (int) ((((float)h) /(imageBounds.height())) * w);
            }
            imageBounds = new Rect(0,0,w,h);
            if (w > canvasWidth) {
                final float reduceRatio = (float) w / canvasWidth;
                rect = new Rect(
                        0,
                        0,
                        canvasWidth,
                        (int) (imageBounds.height() / reduceRatio + .5F)
                );
            } else {
                rect = imageBounds;
            }
            return rect;
        }

        final Rect rect;

        final ImageSize.Dimension width = imageSize.width;
        final ImageSize.Dimension height = imageSize.height;

        final int imageWidth = imageBounds.width();
        final int imageHeight = imageBounds.height();

        final float ratio = (float) imageWidth / imageHeight;

        if (width != null) {

            final int w;
            final int h;

            if (UNIT_PERCENT.equals(width.unit)) {
                w = (int) (canvasWidth * (width.value / 100.F) + .5F);
            } else {
                w = resolveAbsolute(width, imageWidth, textSize);
            }

            if (height == null
                    || UNIT_PERCENT.equals(height.unit)) {
                h = (int) (w / ratio + .5F);
            } else {
                h = resolveAbsolute(height, imageHeight, textSize);
            }

            rect = new Rect(0, 0, w, h);

        } else if (height != null) {

            if (!UNIT_PERCENT.equals(height.unit)) {
                final int h = resolveAbsolute(height, imageHeight, textSize);
                final int w = (int) (h * ratio + .5F);
                rect = new Rect(0, 0, w, h);
            } else {
                rect = imageBounds;
            }
        } else {
            rect = imageBounds;
        }

        return rect;
    }

    private int dpToPx(Context context, float dp){
        if (context != null) {
            float density = context.getResources().getDisplayMetrics().density;
            return Math.round(dp * density);
        }
        return Math.round(dp * 2);
    }

    protected int resolveAbsolute(@NonNull ImageSize.Dimension dimension, int original, float textSize) {
        final int out;
        if (UNIT_EM.equals(dimension.unit)) {
            out = (int) (dimension.value * textSize + .5F);
        } else {
            out = (int) (dimension.value + .5F);
        }
        return out;
    }
}
