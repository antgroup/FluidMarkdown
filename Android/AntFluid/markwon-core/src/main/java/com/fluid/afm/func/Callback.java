package com.fluid.afm.func;

public interface Callback<T> {

    /**
     * 成功
     *
     * @param t result
     */
    void onSuccess(T t);

    /**
     * 失败
     */
    void onFail();
}
