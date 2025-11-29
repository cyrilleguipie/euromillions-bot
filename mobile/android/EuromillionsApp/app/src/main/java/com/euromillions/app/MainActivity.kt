package com.euromillions.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.euromillions.app.data.Grid
import com.euromillions.app.ui.GridDetailScreen
import com.euromillions.app.ui.GridsScreen
import com.euromillions.app.ui.HistoryScreen
import com.euromillions.app.ui.theme.EuromillionsAppTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            EuromillionsAppTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    EuromillionsApp()
                }
            }
        }
    }
}

@Composable
fun EuromillionsApp() {
    val navController = rememberNavController()
    var selectedGrid by remember { mutableStateOf<Grid?>(null) }
    
    NavHost(navController = navController, startDestination = "grids") {
        composable("grids") {
            GridsScreen(
                onNavigateToGrid = { grid ->
                    selectedGrid = grid
                    navController.navigate("gridDetail")
                },
                onNavigateToHistory = {
                    navController.navigate("history")
                }
            )
        }
        
        composable("gridDetail") {
            selectedGrid?.let { grid ->
                GridDetailScreen(
                    grid = grid,
                    onNavigateBack = { navController.popBackStack() }
                )
            }
        }
        
        composable("history") {
            HistoryScreen(
                onNavigateBack = { navController.popBackStack() }
            )
        }
    }
}
