package com.radio.grradio

import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class NativeAdFactoryImpl(private val layoutInflater: LayoutInflater) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {

        val adView = layoutInflater.inflate(
            R.layout.native_ad_list_tile,
            null
        ) as NativeAdView

        with(adView) {
            headlineView = findViewById<TextView>(R.id.ad_headline).also {
                it.text = nativeAd.headline
            }
            bodyView = findViewById<TextView>(R.id.ad_body).also {
                it.text = nativeAd.body
                it.visibility = if (nativeAd.body != null) View.VISIBLE else View.GONE
            }
            iconView = findViewById<ImageView>(R.id.ad_icon).also {
                val icon = nativeAd.icon
                if (icon != null) {
                    it.setImageDrawable(icon.drawable)
                    it.visibility = View.VISIBLE
                } else {
                    it.visibility = View.GONE
                }
            }
            callToActionView = findViewById<Button>(R.id.ad_call_to_action).also {
                it.text = nativeAd.callToAction
                it.visibility =
                    if (nativeAd.callToAction != null) View.VISIBLE else View.GONE
            }
            setNativeAd(nativeAd)
        }

        return adView
    }
}