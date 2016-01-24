//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

public protocol DocumentStyleType {
	func wrap(str: String) -> String
}

extension DocumentStyleType {
	func wrap(str: String) -> String {
		return ""
	}
}

struct DocumentStyle: DocumentStyleType {
	
	enum Intensity: UInt8, HasCodes {
		case Bold = 1
		case Faint = 2
	}
	
	enum Underline: UInt8, HasCodes {
		case Single = 4
		case Double = 21
	}
	
	enum Blink: UInt8, HasCodes {
		case Slow = 5
		case Rapid = 6
	}
	
	struct Color {
		enum ColorInfo {
			case Plain(PlainColor)
			case Custom(CustomColor)
			
			struct PlainColor {
				enum Color: UInt8 {
					case Black = 30
					case Red
					case Green
					case Yellow
					case Blue
					case Magenta
					case Cyan
					case White
				}
				
				enum Intensity {
					case Dull
					case Vivid
				}
				
				let color: Color
				let intensity: Intensity
			}
			
			enum CustomColor {
				case RGB (UInt8, UInt8, UInt8)
				case Custom (UInt8)
			}
		}
		
		enum Layer {
			case Foreground
			case Background
		}
		
		let color: ColorInfo
		let layer: Layer
		
		init(_ intensity: ColorInfo.PlainColor.Intensity, foreground c: ColorInfo.PlainColor.Color){
			let colorInfo = ColorInfo.PlainColor(color: c, intensity: intensity)
			color = .Plain(colorInfo)
			layer = .Foreground
		}
		
		init(_ intensity: ColorInfo.PlainColor.Intensity, background c: ColorInfo.PlainColor.Color){
			let colorInfo = ColorInfo.PlainColor(color: c, intensity: intensity)
			color = .Plain(colorInfo)
			layer = .Background
		}
		
		init(foregroundCustomColor: ColorInfo.CustomColor){
			color = .Custom(foregroundCustomColor)
			layer = .Foreground
		}
		
		init(backgroundCustomColor: ColorInfo.CustomColor){
			color = .Custom(backgroundCustomColor)
			layer = .Background
		}
		
		var codes: [UInt8] {
			switch color {
			case let .Plain(info):
				let layerCode: UInt8 = layer == .Foreground ? 0 : 10
				let intensityCode: UInt8 = info.intensity == .Dull ? 0 : 60
				return [info.color.rawValue + layerCode + intensityCode]
			
			case let .Custom(info):
				let layerCode: UInt8 = layer == .Foreground ? 38 : 48
				switch info {
				case let .Custom(x):
					return [layerCode, 5, x]
				case let .RGB(r, g, b):
					return [layerCode, 2, r, g, b]
				}
			}
		}
	}
	
	var intensity: Intensity?
	var underline: Underline?
	var blink: Blink?
	var color: Color?
	
	var codes: [UInt8] {
		let defaultValue: [UInt8]? -> [UInt8] = fromOptional([])
		return defaultValue(intensity?.codes)
			+ defaultValue(underline?.codes)
			+ defaultValue(blink?.codes)
			+ defaultValue(color?.codes)
	}
}

protocol HasCodes: RawRepresentable {
	typealias RawValue = UInt8
	var codes: [RawValue] { get }
}

extension HasCodes {
	var codes: [RawValue] {
		return [self.rawValue]
	}
}