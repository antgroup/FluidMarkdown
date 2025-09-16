package io.noties.markwon.image;

import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.fluid.afm.func.IImageClickCallback;

import java.util.concurrent.ConcurrentHashMap;

import io.noties.markwon.MarkwonConfiguration;
import io.noties.markwon.RenderProps;
import io.noties.markwon.SpanFactory;

public class ImageSpanFactory implements SpanFactory {

    public static final String TAG = "MD_ImageSpanFactory";
    public ConcurrentHashMap<String,AsyncDrawableSpan> cacheAsyncDrawableSpan = new ConcurrentHashMap<>();
    private boolean mIsStreamOutput;

    private IImageClickCallback mClickCallback ;

    public ImageSpanFactory(){
    }
    @Nullable
    @Override
    public Object getSpans(@NonNull MarkwonConfiguration configuration, @NonNull RenderProps props) {
        String destination = ImageProps.DESTINATION.require(props);
        ConcurrentHashMap<String,AsyncDrawableSpan> cache = cacheAsyncDrawableSpan;
        AsyncDrawableSpan cacheSpan = cache.get(destination);
        Log.d(TAG," destination = " + destination + " cacheSpan = " + cacheSpan + "isStreamOutput = " + mIsStreamOutput);
        if(isIsStreamOutput() && cacheSpan != null){
            Log.d(TAG,"ready to set cacheSpan");
            return cacheSpan;
        }else {
            Log.d(TAG,"set new AsyncDrawableSpan");
            AsyncDrawableSpan asyncDrawableSpan =  new AsyncDrawableSpan(
                    configuration.theme(),
                    new AsyncDrawable(
                            ImageProps.DESTINATION.require(props),
                            configuration.asyncDrawableLoader(),
                            configuration.imageSizeResolver(),
                            ImageProps.IMAGE_SIZE.get(props)
                    ),
                    AsyncDrawableSpan.ALIGN_CENTER,
                    ImageProps.REPLACEMENT_TEXT_IS_LINK.get(props, false),
                    mClickCallback
            );
            cache.put(destination,asyncDrawableSpan);
            return asyncDrawableSpan;
        }
    }
    public void setImageCallback(IImageClickCallback clickCallback) {
        mClickCallback = clickCallback;
    }

    private boolean isIsStreamOutput() {
        return mIsStreamOutput;
    }

    public void onStreamOutStateChanged(boolean isStreamingOutput) {
        mIsStreamOutput = isStreamingOutput;
    }
}
