package com.fluid.afm.utils;

import android.content.Context;
import android.graphics.Color;
import android.text.TextUtils;

import com.fluid.afm.ContextHolder;

public class ParseUtil {

    public static Integer parseColor(String color) {
        return parseColor(color, 0);
    }

    public static Integer parseColor(String color, Integer defaultValue) {
        try {
            if (TextUtils.isEmpty(color)) {
                return defaultValue;
            }
            return Color.parseColor(color);
        } catch (Throwable e) {
            MDLogger.e("ColorParseUtil", "parseColor failed:color=" + color);
        }
        return defaultValue;
    }

    public static float parseFloat(String str, float def) {
        try {
            return Float.parseFloat(str);
        } catch (Throwable e) {
            MDLogger.e("ColorParseUtil", "parseFloat failed:str=" + str);
        }
        return def;
    }

    public static int parseInt(String str, int def) {
        try {
            return Integer.parseInt(str);
        } catch (Throwable e) {
            MDLogger.e("ColorParseUtil", "parseInt failed:str=" + str);
        }
        return def;
    }

    public static int parseDp(String str) {
        return parseDp(ContextHolder.getContext(), str, 0);
    }

    public static int parseDp(String str, int def) {
        return parseDp(ContextHolder.getContext(), str, def);
    }

    public static int parseDp(Context context, String str, int def) {
        if (str == null) {
            return def;
        }
        if (!TextUtils.isDigitsOnly(str)) {
            if (str.endsWith("rpx")) {
                try {
                    return (int) Utils.rpxToPx(Float.parseFloat(str.substring(0, str.length() - 3)), context);
                } catch (Throwable e) {
                    MDLogger.e("ColorParseUtil", "parseDp failed:str=" + str);
                }
                return def;
            } else if (str.endsWith("px")) {
                str = str.substring(0, str.length() - 2);
            }
        }
        return Utils.dpToPx(context, parseFloat(str, def));
    }

    public static float parsePercent(String str, float def) {
        try {
            String percentStr = str.substring(0, str.length() - 1);
            return parseFloat(percentStr, def) / 100;
        } catch (Throwable throwable) {
            MDLogger.e("ColorParseUtil", "parsePercent failed:str=" + str);
        }
        return def;
    }

    public static int parseColorWithRGBA(String str) {
        str = str.toLowerCase();
        // #eee
        if (!str.startsWith("#")) {
            return parseColor(str);
        }

        str = str.replace("#", "");
        if (!(str.length() == 3 || str.length() == 6 || str.length() == 8)) {
            return 0;
        }
        String rString = "";
        String gString = "";
        String bString = "";
        String aString = "ff";
        if (str.length() == 3) {
            rString += str.substring(0, 1);
            rString += rString;
            gString += str.substring(1, 2);
            gString += gString;
            bString += str.substring(2, 3);
            bString += bString;
        } else if (str.length() == 6) {
            rString = str.substring(0, 2);
            gString = str.substring(2, 4);
            bString = str.substring(4, 6);
        } else {
            rString = str.substring(0, 2);
            gString = str.substring(2, 4);
            bString = str.substring(4, 6);
            aString = str.substring(6, 8);
        }

        // Scan values
        int r, g, b, a;
        r = Integer.parseInt(rString, 16);
        g = Integer.parseInt(gString, 16);
        b = Integer.parseInt(bString, 16);
        a = Integer.parseInt(aString, 16);
        return Color.argb(a, r, g, b);
    }

}
