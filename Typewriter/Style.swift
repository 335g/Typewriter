//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

protocol DocumentStyleType {
	var codes: [UInt8] { get }
	func wrap(str: String) -> String
}

extension DocumentStyleType {
	func wrap(str: String) -> String {
		let escape = "\u{001B}["
		let prefix = escape + codes.map(String.init).joinWithSeparator(";") + "m"
		let suffix = escape + "0m"
		
		return prefix + str + suffix
	}
}

public struct DocumentStyle: DocumentStyleType, Equatable {
	
	public enum Intensity: UInt8, HasCodes {
		case Bold = 1
		case Faint = 2
	}
	
	public enum Underline: UInt8, HasCodes {
		case Single = 4
		case Double = 21
	}
	
	public enum Blink: UInt8, HasCodes {
		case Slow = 5
		case Rapid = 6
	}
	
	public struct Color: Equatable {
		public enum ColorInfo: Equatable {
			case Plain(PlainColor)
			case Custom(CustomColor)
			
			public struct PlainColor: Equatable {
				public enum Color: UInt8 {
					case Black = 30
					case Red
					case Green
					case Yellow
					case Blue
					case Magenta
					case Cyan
					case White
				}
				
				public enum Intensity {
					case Dull
					case Vivid
				}
				
				let color: Color
				let intensity: Intensity
			}
			
			public enum CustomColor: Equatable {
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
		
		public init(_ intensity: ColorInfo.PlainColor.Intensity, foreground c: ColorInfo.PlainColor.Color){
			let colorInfo = ColorInfo.PlainColor(color: c, intensity: intensity)
			color = .Plain(colorInfo)
			layer = .Foreground
		}
		
		public init(_ intensity: ColorInfo.PlainColor.Intensity, background c: ColorInfo.PlainColor.Color){
			let colorInfo = ColorInfo.PlainColor(color: c, intensity: intensity)
			color = .Plain(colorInfo)
			layer = .Background
		}
		
		public init(foregroundCustomColor: ColorInfo.CustomColor){
			color = .Custom(foregroundCustomColor)
			layer = .Foreground
		}
		
		public init(backgroundCustomColor: ColorInfo.CustomColor){
			color = .Custom(backgroundCustomColor)
			layer = .Background
		}
		
		public var codes: [UInt8] {
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
	
	init(intensity: Intensity? = nil, underline: Underline? = nil, blink: Blink? = nil, color: Color? = nil) {
		self.intensity = intensity
		self.underline = underline
		self.blink = blink
		self.color = color
	}
	
	var codes: [UInt8] {
		let defaultValue: [UInt8]? -> [UInt8] = { x in
			switch x {
			case .None:
				return []
			case let .Some(a):
				return a
			}
		}
		return defaultValue(intensity?.codes)
			+ defaultValue(underline?.codes)
			+ defaultValue(blink?.codes)
			+ defaultValue(color?.codes)
	}
	
	func merge(x: DocumentStyle) -> DocumentStyle {
		var style = self
		
		if let intensity = x.intensity	{ style.intensity = intensity }
		if let underline = x.underline	{ style.underline = underline }
		if let blink = x.blink			{ style.blink = blink }
		if let color = x.color			{ style.color = color }
		
		return style
	}
}

public func == (lhs: DocumentStyle.Color.ColorInfo.PlainColor, rhs: DocumentStyle.Color.ColorInfo.PlainColor) -> Bool {
	
	return lhs.color == rhs.color && lhs.intensity == rhs.intensity
}

public func == (lhs: DocumentStyle.Color.ColorInfo.CustomColor, rhs: DocumentStyle.Color.ColorInfo.CustomColor) -> Bool {
	
	switch (lhs, rhs) {
	case let (.RGB(lr, lg, lb), .RGB(rr, rg, rb)):
		return lr == rr && lg == rg && lb == rb
	case let (.Custom(l), .Custom(r)):
		return l == r
	default:
		return false
	}
}

public func == (lhs: DocumentStyle.Color.ColorInfo, rhs: DocumentStyle.Color.ColorInfo) -> Bool {
	switch (lhs, rhs) {
	case let (.Plain(l), .Plain(r)):
		return l == r
	case let (.Custom(l), .Custom(r)):
		return l == r
	default:
		return false
	}
}

public func == (lhs: DocumentStyle.Color, rhs: DocumentStyle.Color) -> Bool {
	return lhs.color == rhs.color && lhs.layer == rhs.layer
}

public func == (lhs: DocumentStyle, rhs: DocumentStyle) -> Bool {
	return lhs.intensity == rhs.intensity
		&& lhs.blink == rhs.blink
		&& lhs.underline == rhs.underline
		&& lhs.color == rhs.color
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