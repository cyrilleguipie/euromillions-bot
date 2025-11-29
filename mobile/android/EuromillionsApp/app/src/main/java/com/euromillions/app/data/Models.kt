package com.euromillions.app.data

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.KSerializer
import kotlinx.serialization.descriptors.PrimitiveKind
import kotlinx.serialization.descriptors.PrimitiveSerialDescriptor
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

// Custom serializers for dates
object LocalDateSerializer : KSerializer<LocalDate> {
    private val formatter = DateTimeFormatter.ISO_LOCAL_DATE
    
    override val descriptor: SerialDescriptor =
        PrimitiveSerialDescriptor("LocalDate", PrimitiveKind.STRING)
    
    override fun serialize(encoder: Encoder, value: LocalDate) {
        encoder.encodeString(value.format(formatter))
    }
    
    override fun deserialize(decoder: Decoder): LocalDate {
        return LocalDate.parse(decoder.decodeString(), formatter)
    }
}

object LocalDateTimeSerializer : KSerializer<LocalDateTime> {
    private val formatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME
    
    override val descriptor: SerialDescriptor =
        PrimitiveSerialDescriptor("LocalDateTime", PrimitiveKind.STRING)
    
    override fun serialize(encoder: Encoder, value: LocalDateTime) {
        encoder.encodeString(value.format(formatter))
    }
    
    override fun deserialize(decoder: Decoder): LocalDateTime {
        val dateString = decoder.decodeString()
        // Handle both with and without 'T' separator and fractional seconds
        return try {
            LocalDateTime.parse(dateString, DateTimeFormatter.ISO_LOCAL_DATE_TIME)
        } catch (e: Exception) {
            // Fallback for formats without time component
            LocalDate.parse(dateString.substringBefore('T'), DateTimeFormatter.ISO_LOCAL_DATE)
                .atStartOfDay()
        }
    }
}

@Serializable
data class Draw(
    val id: Int,
    @Serializable(with = LocalDateSerializer::class)
    val date: LocalDate,
    val numbers: List<Int>,
    val stars: List<Int>
)

@Serializable
data class Grid(
    val id: Int,
    @SerialName("draw_date")
    @Serializable(with = LocalDateSerializer::class)
    val drawDate: LocalDate,
    val numbers: List<Int>,
    val stars: List<Int>,
    @SerialName("created_at")
    @Serializable(with = LocalDateTimeSerializer::class)
    val createdAt: LocalDateTime? = null
)

@Serializable
data class NewGrid(
    @SerialName("draw_date")
    @Serializable(with = LocalDateSerializer::class)
    val drawDate: LocalDate,
    val numbers: List<Int>,
    val stars: List<Int>
)
