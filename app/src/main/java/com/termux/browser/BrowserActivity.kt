package com.termux.browser

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.webkit.WebView

class BrowserActivity : Activity() {

    companion object {
        @SuppressLint("StaticFieldLeak")
        var instance: BrowserActivity? = null

        var webView: WebView? = null
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        instance = this

        // HTTPサーバー起動
        startService(Intent(this, AutomationService::class.java))

        // フローティングバブルを自動起動
        startService(Intent(this, FloatingBubbleService::class.java))

        // このActivityは非表示（バックグラウンドで動作）
        finish()
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
    }
}
