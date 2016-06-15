//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - DocumentStyleType

protocol DocumentStyleType {
	var codes: [UInt8] { get }
	func wrap(_ str: String) -> String
}

extension DocumentStyleType {
	func wrap(_ str: String) -> String {
		let escape = "\u{001B}["
		let prefix = escape + codes.map(String.init).joined(separator: ";") + "m"
		let suffix = escape + "0m"
		
		return prefix + str + suffix
	}
}

// MARK: - DocumentStyle

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
		
		
		internal init(_ intensity: ColorInfo.PlainColor.Intensity, foreground c: ColorInfo.PlainColor.Color){
			let colorInfo = ColorInfo.PlainColor(color: c, intensity: intensity)
			color = .Plain(colorInfo)
			layer = .Foreground
		}
		
		internal init(_ intensity: ColorInfo.PlainColor.Intensity, background c: ColorInfo.PlainColor.Color){
			let colorInfo = ColorInfo.PlainColor(color: c, intensity: intensity)
			color = .Plain(colorInfo)
			layer = .Background
		}
		
		public init(foreground c: ColorInfo.CustomColor){
			color = .Custom(c)
			layer = .Foreground
		}
		
		public init(background c: ColorInfo.CustomColor){
			color = .Custom(c)
			layer = .Background
		}
		
		public static var black: Color		{ return Color(.Dull, foreground: .Black) }
		public static var red: Color		{ return Color(.Dull, foreground: .Red) }
		public static var green: Color		{ return Color(.Dull, foreground: .Green) }
		public static var yellow: Color		{ return Color(.Dull, foreground: .Yellow) }
		public static var blue: Color		{ return Color(.Dull, foreground: .Blue) }
		public static var magenta: Color	{ return Color(.Dull, foreground: .Magenta) }
		public static var cyan: Color		{ return Color(.Dull, foreground: .Cyan) }
		public static var white: Color		{ return Color(.Dull, foreground: .White) }
		
		public static var onBlack: Color	{ return Color(.Dull, background: .Black) }
		public static var onRed: Color		{ return Color(.Dull, background: .Red) }
		public static var onGreen: Color	{ return Color(.Dull, background: .Green) }
		public static var onYellow: Color	{ return Color(.Dull, background: .Yellow) }
		public static var onBlue: Color		{ return Color(.Dull, background: .Blue) }
		public static var onMagenta: Color	{ return Color(.Dull, background: .Magenta) }
		public static var onCyan: Color		{ return Color(.Dull, background: .Cyan) }
		public static var onWhite: Color	{ return Color(.Dull, background: .White) }
		
		public static var vividBlack: Color		{ return Color(.Vivid, foreground: .Black) }
		public static var vividRed: Color		{ return Color(.Vivid, foreground: .Red) }
		public static var vividGreen: Color		{ return Color(.Vivid, foreground: .Green) }
		public static var vividYellow: Color	{ return Color(.Vivid, foreground: .Yellow) }
		public static var vividBlue: Color		{ return Color(.Vivid, foreground: .Blue) }
		public static var vividMagenta: Color	{ return Color(.Vivid, foreground: .Magenta) }
		public static var vividCyan: Color		{ return Color(.Vivid, foreground: .Cyan) }
		public static var vividWhite: Color		{ return Color(.Vivid, foreground: .White) }
		
		public static var onVividBlack: Color	{ return Color(.Vivid, background: .Black) }
		public static var onVividRed: Color		{ return Color(.Vivid, background: .Red) }
		public static var onVividGreen: Color	{ return Color(.Vivid, background: .Green) }
		public static var onVividYellow: Color	{ return Color(.Vivid, background: .Yellow) }
		public static var onVividBlue: Color	{ return Color(.Vivid, background: .Blue) }
		public static var onVividMagenta: Color	{ return Color(.Vivid, background: .Magenta) }
		public static var onVividCyan: Color	{ return Color(.Vivid, background: .Cyan) }
		public static var onVividWhite: Color	{ return Color(.Vivid, background: .White) }
		
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
		let defaultValue: ([UInt8]?) -> [UInt8] = { x in
			switch x {
			case .none:
				return []
			case let .some(a):
				return a
			}
		}
		return defaultValue(intensity?.codes)
			+ defaultValue(underline?.codes)
			+ defaultValue(blink?.codes)
			+ defaultValue(color?.codes)
	}
	
	func merge(_ x: DocumentStyle) -> DocumentStyle {
		var style = self
		
		if let intensity = x.intensity	{ style.intensity = intensity }
		if let underline = x.underline	{ style.underline = underline }
		if let blink = x.blink			{ style.blink = blink }
		if let color = x.color			{ style.color = color }
		
		return style
	}
}

// MARK: DocumentStyle.Family : Equatable

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

// MARK: - HasCodes

protocol HasCodes: RawRepresentable {
	associatedtype RawValue = UInt8
	var codes: [RawValue] { get }
}

extension HasCodes {
	var codes: [RawValue] {
		return [self.rawValue]
	}
}
