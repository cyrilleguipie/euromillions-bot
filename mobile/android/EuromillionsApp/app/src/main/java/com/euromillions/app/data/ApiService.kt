package com.euromillions.app.data

import retrofit2.http.GET

interface ApiService {
    @GET("history")
    suspend fun fetchHistory(): String
    
    @GET("generate")
    suspend fun generateGrids(): List<NewGrid>
    
    @GET("grids")
    suspend fun fetchGrids(): List<Grid>
}
