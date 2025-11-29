package com.euromillions.app.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.euromillions.app.data.ApiClient
import com.euromillions.app.data.Grid
import com.google.accompanist.swiperefresh.SwipeRefresh
import com.google.accompanist.swiperefresh.rememberSwipeRefreshState
import kotlinx.coroutines.launch
import java.time.format.DateTimeFormatter

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GridsScreen(onNavigateToGrid: (Grid) -> Unit, onNavigateToHistory: () -> Unit) {
    var grids by remember { mutableStateOf<List<Grid>>(emptyList()) }
    var isLoading by remember { mutableStateOf(false) }
    var isGenerating by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    
    val scope = rememberCoroutineScope()
    
    // Load grids on first composition
    LaunchedEffect(Unit) {
        loadGrids(
            onLoading = { isLoading = it },
            onSuccess = { grids = it },
            onError = { errorMessage = it }
        )
    }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("My Grids") },
                actions = {
                    IconButton(onClick = { onNavigateToHistory() }) {
                        Icon(Icons.Default.Refresh, contentDescription = "History")
                    }
                }
            )
        },
        floatingActionButton = {
            ExtendedFloatingActionButton(
                onClick = {
                    scope.launch {
                        generateGrids(
                            onLoading = { isGenerating = it },
                            onSuccess = {
                                // Reload grids after generation
                                loadGrids(
                                    onLoading = { isLoading = it },
                                    onSuccess = { grids = it },
                                    onError = { errorMessage = it }
                                )
                            },
                            onError = { errorMessage = it }
                        )
                    }
                },
                icon = { Icon(Icons.Default.Add, contentDescription = "Generate") },
                text = { Text(if (isGenerating) "Generating..." else "Generate") }
            )
        }
    ) { padding ->
        SwipeRefresh(
            state = rememberSwipeRefreshState(isLoading),
            onRefresh = {
                scope.launch {
                    loadGrids(
                        onLoading = { isLoading = it },
                        onSuccess = { grids = it },
                        onError = { errorMessage = it }
                    )
                }
            },
            modifier = Modifier.padding(padding)
        ) {
            if (grids.isEmpty() && !isLoading) {
                EmptyGridsView()
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    items(grids) { grid ->
                        GridCard(grid = grid, onClick = { onNavigateToGrid(grid) })
                    }
                }
            }
        }
        
        // Error snackbar
        errorMessage?.let { error ->
            Snackbar(
                modifier = Modifier.padding(16.dp),
                action = {
                    TextButton(onClick = { errorMessage = null }) {
                        Text("Dismiss")
                    }
                }
            ) {
                Text(error)
            }
        }
    }
}

@Composable
fun GridCard(grid: Grid, onClick: () -> Unit) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                text = grid.drawDate.format(DateTimeFormatter.ofPattern("MMMM d, yyyy")),
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
            
            // Numbers
            Row(
                horizontalArrangement = Arrangement.spacedBy(4.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Numbers:",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                grid.numbers.forEach { number ->
                    NumberBall(number = number, color = MaterialTheme.colorScheme.primary)
                }
            }
            
            // Stars
            Row(
                horizontalArrangement = Arrangement.spacedBy(4.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Stars:",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                grid.stars.forEach { star ->
                    NumberBall(number = star, color = Color(0xFFFF9800))
                }
            }
            
            grid.createdAt?.let { createdAt ->
                Text(
                    text = "Generated: ${createdAt.format(DateTimeFormatter.ofPattern("MMM d, h:mm a"))}",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

@Composable
fun NumberBall(number: Int, color: Color) {
    Box(
        modifier = Modifier
            .size(28.dp)
            .background(color, CircleShape),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = number.toString(),
            style = MaterialTheme.typography.bodySmall,
            color = Color.White,
            fontWeight = FontWeight.Bold
        )
    }
}

@Composable
fun EmptyGridsView() {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Icon(
                imageVector = Icons.Default.Add,
                contentDescription = null,
                modifier = Modifier.size(64.dp),
                tint = MaterialTheme.colorScheme.primary
            )
            Text(
                text = "No grids yet",
                style = MaterialTheme.typography.titleLarge
            )
            Text(
                text = "Tap the button below to generate your first grids",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

suspend fun loadGrids(
    onLoading: (Boolean) -> Unit,
    onSuccess: (List<Grid>) -> Unit,
    onError: (String) -> Unit
) {
    onLoading(true)
    try {
        val grids = ApiClient.apiService.fetchGrids()
        onSuccess(grids)
    } catch (e: Exception) {
        onError(e.message ?: "Failed to load grids")
    } finally {
        onLoading(false)
    }
}

suspend fun generateGrids(
    onLoading: (Boolean) -> Unit,
    onSuccess: () -> Unit,
    onError: (String) -> Unit
) {
    onLoading(true)
    try {
        ApiClient.apiService.generateGrids()
        onSuccess()
    } catch (e: Exception) {
        onError(e.message ?: "Failed to generate grids")
    } finally {
        onLoading(false)
    }
}
