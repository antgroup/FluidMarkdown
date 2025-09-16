package com.fluid.markdown

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.widget.NestedScrollView
import com.fluid.afm.AFMInitializer
import com.fluid.afm.R
import com.fluid.afm.markdown.ElementClickEventCallback
import com.fluid.afm.markdown.html.SpanTextClickableSpan.ClickableTextType
import com.fluid.afm.markdown.model.EventModel
import com.fluid.afm.markdown.widget.PrinterMarkDownTextView
import com.fluid.afm.styles.MarkdownStyles
import com.fluid.afm.styles.TitleStyle
import com.fluid.markdown.demos.ListActivity
import com.fluid.markdown.demos.PrinterActivity


class MainActivity : AppCompatActivity() {
    companion object {
        @JvmStatic
        var initialed = false
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.layout_main)
        val markdown = resources.getString(R.string.toPrinter) + resources.getString(R.string.toList) + resources.getString(R.string.sample)

        val markdownTextView = findViewById<PrinterMarkDownTextView>(R.id.textView)
        if (!initialed) {
            initialed = true
            AFMInitializer.init(this, null, MyImageHandler(), null)
        }
        val styles =  MarkdownStyles.getDefaultStyles()
        styles.linkStyle().icon("local://mipmap/link")
        styles.setTitleStyle(0, TitleStyle.create(1.5f).icon("local://mipmap/title"))
        markdownTextView.init(styles, object : ElementClickEventCallback {
                override fun onLinkClicked(params: Map<String?, Any?>?): Boolean {
                    val url = params?.get(ElementClickEventCallback.PARAM_KEY_LINK) as String?
                    if(url.equals("open://printer")) {
                        startActivity(Intent(this@MainActivity, PrinterActivity::class.java))
                        return true
                    } else if (url.equals("open://list_printer")) {
                        startActivity(Intent(this@MainActivity, ListActivity::class.java))
                        return true
                    }
                    Toast.makeText(this@MainActivity, "link click$url", Toast.LENGTH_SHORT).show()
                    return false
                }

                override fun onFootnoteClicked(index: String) {
                    Toast.makeText(this@MainActivity, "footnote click$index", Toast.LENGTH_SHORT).show()

                }

                override fun onImageClicked(url: String?, description: String?) {
                    Toast.makeText(this@MainActivity, "onImageClicked click-$description", Toast.LENGTH_SHORT).show()
                }

                override fun onTextClickableSpanClicked(
                    widget: View?,
                    link: String?,
                    entityID: String?,
                    type: ClickableTextType?
                ): Boolean {
                    Toast.makeText(this@MainActivity, "clickable click link$link type$type entityID$entityID", Toast.LENGTH_SHORT).show()
                    return false
                }

                override fun exposureSpmBehavior(models: MutableList<EventModel>?) {
                    Log.d("exposureSpmBehavior", models.toString())
                }
            }
        )

        markdownTextView.setMarkdownText(markdown)
        val scroller = findViewById<NestedScrollView>(R.id.scrollView)

        scroller.setOnScrollChangeListener(object : NestedScrollView.OnScrollChangeListener {
            override fun onScrollChange(
                v: NestedScrollView,
                scrollX: Int,
                scrollY: Int,
                oldScrollX: Int,
                oldScrollY: Int
            ) {
                markdownTextView.handleExposureSpm()
            }

        })
    }
}