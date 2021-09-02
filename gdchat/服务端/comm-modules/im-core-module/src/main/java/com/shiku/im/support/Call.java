package com.shiku.im.support;

@FunctionalInterface
public interface Call<T> {

    Object execute(T obj);
}
