package com.euromillions.app.data

import com.jakewharton.retrofit2.converter.kotlinx.serialization.asConverterFactory
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import java.util.concurrent.TimeUnit

object ApiClient {
    // Configure this with your deployed API URL
    // For local testing: "http://10.0.2.2:8080" (Android emulator)
    // For production: your Render.com URL
    private const val BASE_URL = "http://10.0.2.2:8080/"
    
    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
    }
    
    private val okHttpClient = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .build()
    
    private val retrofit = Retrofit.Builder()
        .baseUrl(BASE_URL)
        .client(okHttpClient)
        .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
        .build()
    
    val apiService: ApiService = retrofit.create(ApiService::class.java)
}
