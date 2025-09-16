package io.noties.markwon;

import android.content.Context;
import android.widget.TextView;

import androidx.annotation.NonNull;

import org.commonmark.parser.Parser;

import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

import io.noties.markwon.core.MarkwonTheme;

/**
 * @since 3.0.0
 */
class MarkwonBuilderImpl implements Markwon.Builder {

    private final Context context;

    private final CopyOnWriteArrayList<MarkwonPlugin> plugins;

    private TextView.BufferType bufferType = TextView.BufferType.SPANNABLE;

    private Markwon.TextSetter textSetter;

    // @since 4.4.0
    private boolean fallbackToRawInputWhenEmpty = true;
    private MarkwonTheme theme;

    MarkwonBuilderImpl(@NonNull Context context) {
        this.context = context;
        plugins = new CopyOnWriteArrayList<>();
    }

    MarkwonBuilderImpl(@NonNull Context context, List<MarkwonPlugin> plugins) {
        this.context = context;
        if (plugins != null) {
            this.plugins = new CopyOnWriteArrayList<>(plugins);
        } else {
            this.plugins = new CopyOnWriteArrayList<>();
        }
    }

    @NonNull
    @Override
    public Markwon.Builder bufferType(@NonNull TextView.BufferType bufferType) {
        this.bufferType = bufferType;
        return this;
    }

    @NonNull
    @Override
    public Markwon.Builder textSetter(@NonNull Markwon.TextSetter textSetter) {
        this.textSetter = textSetter;
        return this;
    }

    @NonNull
    @Override
    public Markwon.Builder usePlugin(@NonNull MarkwonPlugin plugin) {
        plugins.add(plugin);
        return this;
    }

    @NonNull
    @Override
    public Markwon.Builder usePlugins(@NonNull Iterable<? extends MarkwonPlugin> plugins) {

        final Iterator<? extends MarkwonPlugin> iterator = plugins.iterator();

        MarkwonPlugin plugin;

        while (iterator.hasNext()) {
            plugin = iterator.next();
            if (plugin == null) {
                throw new NullPointerException();
            }
            this.plugins.add(plugin);
        }

        return this;
    }

    @NonNull
    @Override
    public Markwon.Builder fallbackToRawInputWhenEmpty(boolean fallbackToRawInputWhenEmpty) {
        this.fallbackToRawInputWhenEmpty = fallbackToRawInputWhenEmpty;
        return this;
    }

    @Override
    public Markwon.Builder setMarkdownTheme(MarkwonTheme theme) {
        this.theme = theme;
        return this;
    }

    @NonNull
    @Override
    public Markwon build() {

        if (plugins.isEmpty()) {
            throw new IllegalStateException("No plugins were added to this builder. Use #usePlugin " +
                    "method to add them");
        }

        // please note that this method must not modify supplied collection
        // if nothing should be done -> the same collection can be returned
        final List<MarkwonPlugin> plugins = preparePlugins(this.plugins);

        final Parser.Builder parserBuilder = new Parser.Builder();

        final MarkwonConfiguration.Builder configurationBuilder = new MarkwonConfiguration.Builder();
        final MarkwonVisitor.Builder visitorBuilder = new MarkwonVisitorImpl.BuilderImpl();
        final MarkwonSpansFactory.Builder spanFactoryBuilder = new MarkwonSpansFactoryImpl.BuilderImpl();

        for (MarkwonPlugin plugin : plugins) {
            plugin.configureParser(parserBuilder);
            plugin.configureConfiguration(configurationBuilder);
            plugin.configureVisitor(visitorBuilder);
            plugin.configureSpansFactory(spanFactoryBuilder);
        }

        final MarkwonConfiguration configuration = configurationBuilder.build(theme, spanFactoryBuilder.build());

        // @since 4.1.1
        // @since 4.1.2 - do not reuse render-props (each render call should have own render-props)
        final MarkwonVisitorFactory visitorFactory = MarkwonVisitorFactory.create(
                visitorBuilder,
                configuration);

        return new MarkwonImpl(
                bufferType,
                textSetter,
                parserBuilder.build(),
                visitorFactory,
                configuration,
                Collections.unmodifiableList(plugins),
                fallbackToRawInputWhenEmpty
        );
    }

    @NonNull
    private static List<MarkwonPlugin> preparePlugins(@NonNull List<MarkwonPlugin> plugins) {
        return new RegistryImpl(plugins).process();
    }
}
