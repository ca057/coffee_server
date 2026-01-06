import gleam/float
import gleam/int
import gleam/json
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/time/timestamp
import glexif/exif_tag
import glexif/exif_tags/color_space
import glexif/exif_tags/components_configuration
import glexif/exif_tags/composite_image
import glexif/exif_tags/exposure_mode
import glexif/exif_tags/exposure_program
import glexif/exif_tags/flash
import glexif/exif_tags/gps_altitude_ref
import glexif/exif_tags/gps_speed_ref
import glexif/exif_tags/metering_mode
import glexif/exif_tags/orientation
import glexif/exif_tags/resolution_unit
import glexif/exif_tags/scene_capture_type
import glexif/exif_tags/scene_type
import glexif/exif_tags/sensing_method
import glexif/exif_tags/white_balance
import glexif/exif_tags/y_cb_cr_positioning
import glexif/units/gps_coordinates

// TODO: add support for Huawei values

pub fn date_time_original_to_timestamp(
  date_time_original: String,
) -> Result(timestamp.Timestamp, Nil) {
  regexp.from_string("(\\d{4}):(\\d{2}):(\\d{2})\\W(\\d{2}):(\\d{2}):(\\d{2})")
  |> result.map(regexp.scan(_, date_time_original))
  |> result.map_error(fn(_) { Nil })
  |> result.try(list.first)
  |> result.try(fn(m) {
    list.try_map(m.submatches, option.to_result(_, Nil))
    |> result.try(fn(parsed) {
      case parsed {
        [year, month, day, hour, minute, second] -> {
          timestamp.parse_rfc3339(
            year
            <> "-"
            <> month
            <> "-"
            <> day
            <> "T"
            <> hour
            <> ":"
            <> minute
            <> ":"
            <> second
            <> "Z",
          )
        }
        _ -> Error(Nil)
      }
    })
  })
}

pub fn export_to_json(exif_data: exif_tag.ExifTagRecord) -> json.Json {
  json.object([
    #(
      "image_description",
      unwrap_option_with(exif_data.image_description, json.string, json.null()),
    ),
    #("make", unwrap_option_with(exif_data.make, json.string, json.null())),
    #("model", unwrap_option_with(exif_data.model, json.string, json.null())),
    #(
      "orientation",
      unwrap_option_with(
        exif_data.orientation,
        fn(orientation) {
          json.string(case orientation {
            orientation.Horizontal -> "Horizontal"
            orientation.InvalidOrientation -> "InvalidOrientation"
            orientation.MirrorHorizontal -> "MirrorHorizontal"
            orientation.MirrorHorizontalAndRotate270CW ->
              "MirrorHorizontalAndRotate270CW"
            orientation.MirrorHorizontalAndRotate90CW ->
              "MirrorHorizontalAndRotate90CW"
            orientation.MirrorVertical -> "MirrorVertical"
            orientation.Rotate180 -> "Rotate180"
            orientation.Rotate270CW -> "Rotate270CW"
            orientation.Rotate90CW -> "Rotate90CW"
          })
        },
        json.null(),
      ),
    ),
    #(
      "x_resolution",
      unwrap_option_with(exif_data.x_resolution, json.int, json.null()),
    ),
    #(
      "y_resolution",
      unwrap_option_with(exif_data.y_resolution, json.int, json.null()),
    ),
    #(
      "resolution_unit",
      unwrap_option_with(
        exif_data.resolution_unit,
        fn(resolution_unit) {
          json.string(case resolution_unit {
            resolution_unit.Centimeters -> "Centimeters"
            resolution_unit.Inches -> "Inches"
            resolution_unit.InvalidResolutionUnit -> "InvalidResolutionUnit"
            resolution_unit.NoResolutionTagUnit -> "NoResolutionTagUnit"
          })
        },
        json.null(),
      ),
    ),
    #(
      "software",
      unwrap_option_with(exif_data.software, json.string, json.null()),
    ),
    #(
      "modify_date",
      unwrap_option_with(exif_data.modify_date, json.string, json.null()),
    ),
    #(
      "host_computer",
      unwrap_option_with(exif_data.host_computer, json.string, json.null()),
    ),
    #(
      "y_cb_cr_positioning",
      unwrap_option_with(
        exif_data.y_cb_cr_positioning,
        fn(y_cb_cr_positioning) {
          json.string(case y_cb_cr_positioning {
            y_cb_cr_positioning.Centered -> "Centered"
            y_cb_cr_positioning.CoSited -> "CoSited"
            y_cb_cr_positioning.InvalidYCbCrPositioning ->
              "InvalidYCbCrPositioning"
          })
        },
        json.null(),
      ),
    ),
    #(
      "exposure_time",
      unwrap_option_with(
        exif_data.exposure_time,
        fn(exposure_time) {
          json.string(
            "1/"
            <> int.divide(exposure_time.denominator, exposure_time.numerator)
            |> result.map(int.to_string)
            |> result.unwrap("ERROR"),
          )
        },
        json.null(),
      ),
    ),
    #(
      "f_number",
      unwrap_option_with(
        exif_data.f_number,
        fn(f_number) {
          json.string(
            int.to_string(f_number.numerator)
            <> "/"
            <> int.to_string(f_number.denominator),
          )
        },
        json.null(),
      ),
    ),
    #(
      "exposure_program",
      unwrap_option_with(
        exif_data.exposure_program,
        fn(exposure_program) {
          json.string(case exposure_program {
            exposure_program.Action -> "Action"
            exposure_program.AperturePriorityAE -> "AperturePriorityAE"
            exposure_program.Bulb -> "Bulb"
            exposure_program.Creative -> "Creative"
            exposure_program.InvalidExposureProgram -> "InvalidExposureProgram"
            exposure_program.Landscape -> "Landscape"
            exposure_program.Manual -> "Manual"
            exposure_program.NotDefined -> "NotDefined"
            exposure_program.Portrait -> "Portrait"
            exposure_program.ProgramAE -> "ProgramAE"
            exposure_program.ShutterSpeedPriorityAE -> "ShutterSpeedPriorityAE"
          })
        },
        json.null(),
      ),
    ),
    #("iso", unwrap_option_with(exif_data.iso, json.int, json.null())),
    #(
      "exif_version",
      unwrap_option_with(exif_data.exif_version, json.string, json.null()),
    ),
    #(
      "date_time_original",
      unwrap_option_with(exif_data.date_time_original, json.string, json.null()),
    ),
    #(
      "create_date",
      unwrap_option_with(exif_data.create_date, json.string, json.null()),
    ),
    #(
      "offset_time",
      unwrap_option_with(exif_data.offset_time, json.string, json.null()),
    ),
    #(
      "offset_time_original",
      unwrap_option_with(
        exif_data.offset_time_original,
        json.string,
        json.null(),
      ),
    ),
    #(
      "offset_time_digitized",
      unwrap_option_with(
        exif_data.offset_time_digitized,
        json.string,
        json.null(),
      ),
    ),
    #(
      "components_configuration",
      unwrap_option_with(
        exif_data.components_configuration,
        fn(components_configuration) {
          json.array(components_configuration, fn(component) {
            json.string(case component {
              components_configuration.B -> "B"
              components_configuration.Cb -> "Cb"
              components_configuration.Cr -> "Cr"
              components_configuration.G -> "G"
              components_configuration.InvalidComponentsConfiguration ->
                "InvalidComponentsConfiguration"
              components_configuration.NA -> "NA"
              components_configuration.R -> "R"
              components_configuration.Y -> "Y"
            })
          })
        },
        json.null(),
      ),
    ),
    #(
      "shutter_speed_value",
      unwrap_option_with(
        exif_data.shutter_speed_value,
        fn(shutter_speed_value) {
          json.string(
            int.to_string(shutter_speed_value.numerator)
            <> "/"
            <> int.to_string(shutter_speed_value.denominator),
          )
        },
        json.null(),
      ),
    ),
    #(
      "aperature_value",
      unwrap_option_with(
        exif_data.aperature_value,
        fn(aperature_value) {
          json.string(
            int.to_string(aperature_value.numerator)
            <> "/"
            <> int.to_string(aperature_value.denominator),
          )
        },
        json.null(),
      ),
    ),
    #(
      "brightness_value",
      unwrap_option_with(exif_data.brightness_value, json.float, json.null()),
    ),
    #(
      "exposure_compensation",
      unwrap_option_with(
        exif_data.exposure_compensation,
        fn(exposure_compensation) {
          json.string(
            int.to_string(exposure_compensation.numerator)
            <> "/"
            <> int.to_string(exposure_compensation.denominator),
          )
        },
        json.null(),
      ),
    ),
    #(
      "metering_mode",
      unwrap_option_with(
        exif_data.metering_mode,
        fn(metering_mode) {
          json.string(case metering_mode {
            metering_mode.Average -> "Average"
            metering_mode.CenterWeightedAverage -> "CenterWeightedAverage"
            metering_mode.InvalidMeteringMode -> "InvalidMeteringMode"
            metering_mode.MultiSegement -> "MultiSegement"
            metering_mode.MultiSpot -> "MultiSpot"
            metering_mode.Other -> "Other"
            metering_mode.Partial -> "Partial"
            metering_mode.Spot -> "Spot"
            metering_mode.UnknownMeteringMode -> "UnknownMeteringMode"
          })
        },
        json.null(),
      ),
    ),
    #(
      "flash",
      unwrap_option_with(
        exif_data.flash,
        fn(flash) {
          json.string(case flash {
            flash.AutoDidNotFire -> "AutoDidNotFire"
            flash.AutoDidNotFireRedEyeReduction ->
              "AutoDidNotFireRedEyeReduction"
            flash.AutoFired -> "AutoFired"
            flash.AutoFiredRedEyeReduction -> "AutoFiredRedEyeReduction"
            flash.AutoFiredRedEyeReductionReturnDetected ->
              "AutoFiredRedEyeReductionReturnDetected"
            flash.AutoFiredRedEyeReductionReturnNotDetected ->
              "AutoFiredRedEyeReductionReturnNotDetected"
            flash.AutoFiredReturnDetected -> "AutoFiredReturnDetected"
            flash.AutoFiredReturnNotDetected -> "AutoFiredReturnNotDetected"
            flash.Fired -> "Fired"
            flash.FiredRedEyeReduction -> "FiredRedEyeReduction"
            flash.FiredRedEyeReductionReturnDetected ->
              "FiredRedEyeReductionReturnDetected"
            flash.FiredRedEyeReductionReturnNotDetected ->
              "FiredRedEyeReductionReturnNotDetected"
            flash.FiredReturnDetected -> "FiredReturnDetected"
            flash.FiredReturnNotDetected -> "FiredReturnNotDetected"
            flash.InvalidFlash -> "InvalidFlash"
            flash.NoFlash -> "NoFlash"
            flash.NoFlashFunction -> "NoFlashFunction"
            flash.OffDidNotFire -> "OffDidNotFire"
            flash.OffDidNotFireReturnNotDetected ->
              "OffDidNotFireReturnNotDetected"
            flash.OffNoFlashFunction -> "OffNoFlashFunction"
            flash.OffRedEyeReduction -> "OffRedEyeReduction"
            flash.OnDidNotFire -> "OnDidNotFire"
            flash.OnFired -> "OnFired"
            flash.OnRedEyeReduction -> "OnRedEyeReduction"
            flash.OnRedEyeReductionReturnDetected ->
              "OnRedEyeReductionReturnDetected"
            flash.OnRedEyeReductionReturnNotDetected ->
              "OnRedEyeReductionReturnNotDetected"
            flash.OnReturnDetected -> "OnReturnDetected"
            flash.OnReturnNotDetected -> "OnReturnNotDetected"
          })
        },
        json.null(),
      ),
    ),
    #(
      "focal_length",
      unwrap_option_with(exif_data.focal_length, json.float, json.null()),
    ),
    #(
      "subject_area",
      unwrap_option_with(
        exif_data.subject_area,
        fn(subject_area) { json.array(subject_area, json.int) },
        json.null(),
      ),
    ),
    #(
      "maker_data",
      unwrap_option_with(
        exif_data.maker_data,
        fn(_) {
          // TODO: Implement maker data serialization
          json.null()
        },
        json.null(),
      ),
    ),
    #(
      "sub_sec_time_original",
      unwrap_option_with(
        exif_data.sub_sec_time_original,
        json.string,
        json.null(),
      ),
    ),
    #(
      "sub_sec_time_digitized",
      unwrap_option_with(
        exif_data.sub_sec_time_digitized,
        json.string,
        json.null(),
      ),
    ),
    #(
      "flash_pix_version",
      unwrap_option_with(exif_data.flash_pix_version, json.string, json.null()),
    ),
    #(
      "color_space",
      unwrap_option_with(
        exif_data.color_space,
        fn(color_space) {
          json.string(case color_space {
            color_space.AdobeRGB -> "AdobeRGB"
            color_space.ICCProfile -> "ICCProfile"
            color_space.InvalidColorSpace -> "InvalidColorSpace"
            color_space.SRGB -> "SRGB"
            color_space.Uncalibrated -> "Uncalibrated"
            color_space.WideGamutRGB -> "WideGamutRGB"
          })
        },
        json.null(),
      ),
    ),
    #(
      "exif_image_width",
      unwrap_option_with(exif_data.exif_image_width, json.int, json.null()),
    ),
    #(
      "exif_image_height",
      unwrap_option_with(exif_data.exif_image_height, json.int, json.null()),
    ),
    #(
      "sensing_method",
      unwrap_option_with(
        exif_data.sensing_method,
        fn(sensing_method) {
          json.string(case sensing_method {
            sensing_method.ColorSequentialArea -> "ColorSequentialArea"
            sensing_method.ColorSequentialLinear -> "ColorSequentialLinear"
            sensing_method.InvalidSensingMethod -> "InvalidSensingMethod"
            sensing_method.OneChipColorArea -> "OneChipColorArea"
            sensing_method.SensingMethodNotDefined -> "SensingMethodNotDefined"
            sensing_method.ThreeChipColorArea -> "ThreeChipColorArea"
            sensing_method.Trilinear -> "Trilinear"
            sensing_method.TwoChipColorArea -> "TwoChipColorArea"
          })
        },
        json.null(),
      ),
    ),
    #(
      "scene_type",
      unwrap_option_with(
        exif_data.scene_type,
        fn(scene_type) {
          json.string(case scene_type {
            scene_type.DirectlyPhotographed -> "DirectlyPhotographed"
          })
        },
        json.null(),
      ),
    ),
    #(
      "exposure_mode",
      unwrap_option_with(
        exif_data.exposure_mode,
        fn(exposure_mode) {
          json.string(case exposure_mode {
            exposure_mode.Auto -> "Auto"
            exposure_mode.AutoBracket -> "AutoBracket"
            exposure_mode.InvalidExposureMode -> "InvalidExposureMode"
            exposure_mode.Manual -> "Manual"
          })
        },
        json.null(),
      ),
    ),
    #(
      "white_balance",
      unwrap_option_with(
        exif_data.white_balance,
        fn(white_balance) {
          json.string(case white_balance {
            white_balance.Auto -> "Auto"
            white_balance.InvalidWhiteBalance -> "InvalidWhiteBalance"
            white_balance.Manual -> "Manual"
          })
        },
        json.null(),
      ),
    ),
    #(
      "focal_length_in_35_mm_format",
      unwrap_option_with(
        exif_data.focal_length_in_35_mm_format,
        json.int,
        json.null(),
      ),
    ),
    #(
      "scene_capture_type",
      unwrap_option_with(
        exif_data.scene_capture_type,
        fn(scene_capture_type) {
          json.string(case scene_capture_type {
            scene_capture_type.InvalidSceneCaptureType ->
              "InvalidSceneCaptureType"
            scene_capture_type.Landscape -> "Landscape"
            scene_capture_type.Night -> "Night"
            scene_capture_type.Other -> "Other"
            scene_capture_type.Portrait -> "Portrait"
            scene_capture_type.Standard -> "Standard"
          })
        },
        json.null(),
      ),
    ),
    #(
      "lens_info",
      unwrap_option_with(
        exif_data.lens_info,
        fn(lens_info) {
          json.array(lens_info, fn(lens) {
            json.string(
              int.to_string(lens.numerator)
              <> "/"
              <> int.to_string(lens.denominator),
            )
          })
        },
        json.null(),
      ),
    ),
    #(
      "lens_make",
      unwrap_option_with(exif_data.lens_make, json.string, json.null()),
    ),
    #(
      "lens_model",
      unwrap_option_with(exif_data.lens_model, json.string, json.null()),
    ),
    #(
      "composite_image",
      unwrap_option_with(
        exif_data.composite_image,
        fn(composite_image) {
          json.string(case composite_image {
            composite_image.CompositeImageCapturedWhileShooting ->
              "CompositeImageCapturedWhileShooting"
            composite_image.GeneralCompositeImage -> "GeneralCompositeImage"
            composite_image.InvalidCompositeImage -> "InvalidCompositeImage"
            composite_image.NotACompositeImage -> "NotACompositeImage"
            composite_image.Unknown -> "Unknown"
          })
        },
        json.null(),
      ),
    ),
    #(
      "gps_latitude_ref",
      unwrap_option_with(exif_data.gps_latitude_ref, json.string, json.null()),
    ),
    #(
      "gps_latitude",
      unwrap_option_with(
        exif_data.gps_latitude,
        fn(gps_latitude) {
          json.string(case gps_latitude {
            gps_coordinates.GPSCoordinates(degrees:, minutes:, seconds:) ->
              int.to_string(degrees)
              <> "°"
              <> int.to_string(minutes)
              <> "'"
              <> float.to_string(seconds)
              <> "''"
            gps_coordinates.InvalidGPSCoordinates -> "invalid"
          })
        },
        json.null(),
      ),
    ),
    #(
      "gps_longitude_ref",
      unwrap_option_with(exif_data.gps_longitude_ref, json.string, json.null()),
    ),
    #(
      "gps_longitude",
      unwrap_option_with(
        exif_data.gps_longitude,
        fn(gps_longitude) {
          json.string(case gps_longitude {
            gps_coordinates.GPSCoordinates(degrees:, minutes:, seconds:) ->
              int.to_string(degrees)
              <> "°"
              <> int.to_string(minutes)
              <> "'"
              <> float.to_string(seconds)
              <> "''"
            gps_coordinates.InvalidGPSCoordinates -> "invalid"
          })
        },
        json.null(),
      ),
    ),
    #(
      "gps_altitude_ref",
      unwrap_option_with(
        exif_data.gps_altitude_ref,
        fn(gps_altitude_ref) {
          json.string(case gps_altitude_ref {
            gps_altitude_ref.AboveSeaLevel -> "AboveSeaLevel"
            gps_altitude_ref.BelowSeaLevel -> "BelowSeaLevel"
            gps_altitude_ref.InvalidGPSAltitudeRef -> "InvalidGPSAltitudeRef"
          })
        },
        json.null(),
      ),
    ),
    #(
      "gps_altitude",
      unwrap_option_with(exif_data.gps_altitude, json.float, json.null()),
    ),
    #(
      "gps_timestamp",
      unwrap_option_with(exif_data.gps_timestamp, json.string, json.null()),
    ),
    #(
      "gps_speed_ref",
      unwrap_option_with(
        exif_data.gps_speed_ref,
        fn(gps_speed_ref) {
          json.string(case gps_speed_ref {
            gps_speed_ref.InvalidGPSSpeedRef -> "InvalidGPSSpeedRef"
            gps_speed_ref.KilometersPerHour -> "KilometersPerHour"
            gps_speed_ref.Knots -> "Knots"
            gps_speed_ref.MilesPerHour -> "MilesPerHour"
          })
        },
        json.null(),
      ),
    ),
    #(
      "gps_speed",
      unwrap_option_with(exif_data.gps_speed, json.float, json.null()),
    ),
  ])
}

fn unwrap_option_with(value: option.Option(a), with: fn(a) -> b, or: b) -> b {
  option.unwrap(option.map(value, with), or)
}
