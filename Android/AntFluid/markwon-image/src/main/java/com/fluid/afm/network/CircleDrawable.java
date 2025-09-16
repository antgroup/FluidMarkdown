package com.fluid.afm.network;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;

public class CircleDrawable {

    public static Drawable createCircleDrawable(Context context, int diameter) {
        // Create a Bitmap with the specified diameter
        Bitmap bitmap = Bitmap.createBitmap(diameter, diameter, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);

        // Create a Paint object to draw the circle
        Paint paint = new Paint();
        paint.setAntiAlias(true);
        paint.setColor(Color.BLUE);

        // Draw the circle
        float radius = diameter / 2f;
        canvas.drawCircle(radius, radius, radius, paint);

        // Set up the Paint for the text
        Paint textPaint = new Paint();
        textPaint.setAntiAlias(true);
        textPaint.setColor(Color.WHITE);
        textPaint.setTextSize(radius); // Adjust text size as needed
        textPaint.setTextAlign(Paint.Align.CENTER);

        // Draw the "1" in the center of the circle
        // Calculate Y position to center text vertically
        float textY = radius - ((textPaint.descent() + textPaint.ascent()) / 2);
        canvas.drawText("1", radius, textY, textPaint);

        // Return a Drawable from the Bitmap
        return new BitmapDrawable(context.getResources(), bitmap);
    }
}
