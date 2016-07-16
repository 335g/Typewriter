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
		case bold = 1
		case faint = 2
	}
	
	public enum Underline: UInt8, HasCodes {
		case single = 4
		case double = 21
	}
	
	public enum Blink: UInt8, HasCodes {
		case slow = 5
		case rapid = 6
	}
	
	public struct Color: Equatable {
		public enum ColorInfo: Equatable {
			case plain(PlainColor)
			case custom(CustomColor)
			
			public struct PlainColor: Equatable {
				public enum Color: UInt8 {
					case black = 30
					case red
					case green
					case yellow
					case blue
					case magenta
					case cyan
					case white
				}
				
				public enum Intensity {
					case dull
					case vivid
				}
				
				let color: Color
				let intensity: Intensity
			}
			
			public enum CustomColor: Equatable {
				case rgb (UInt8, UInt8, UInt8)
				case custom (UInt8)
			}
		}
		
		enum Layer {
			case foreground
			case background
		}
		
		let color: ColorInfo
		let layer: Layer
		
		
		internal init(_ intensity: ColorInfo.PlainColor.Intensity, foreground c: ColorInfo.PlainColor.Color){
			let colorInfo = ColorInfo.PlainColor(color: c, intensity: intensity)
			color = .plain(colorInfo)
			layer = .foreground
		}
		
		internal init(_ intensity: ColorInfo.PlainColor.Intensity, background c: ColorInfo.PlainColor.Color){
			let colorInfo = ColorInfo.PlainColor(color: c, intensity: intensity)
			color = .plain(colorInfo)
			layer = .background
		}
		
		public init(foreground c: ColorInfo.CustomColor){
			color = .custom(c)
			layer = .foreground
		}
		
		public init(background c: ColorInfo.CustomColor){
			color = .custom(c)
			layer = .background
		}
		
		public static var black: Color		{ return Color(.dull, foreground: .black) }
		public static var red: Color		{ return Color(.dull, foreground: .red) }
		public static var green: Color		{ return Color(.dull, foreground: .green) }
		public static var yellow: Color		{ return Color(.dull, foreground: .yellow) }
		public static var blue: Color		{ return Color(.dull, foreground: .blue) }
		public static var magenta: Color	{ return Color(.dull, foreground: .magenta) }
		public static var cyan: Color		{ return Color(.dull, foreground: .cyan) }
		public static var white: Color		{ return Color(.dull, foreground: .white) }
		
		public static var onBlack: Color	{ return Color(.dull, background: .black) }
		public static var onRed: Color		{ return Color(.dull, background: .red) }
		public static var onGreen: Color	{ return Color(.dull, background: .green) }
		public static var onYellow: Color	{ return Color(.dull, background: .yellow) }
		public static var onBlue: Color		{ return Color(.dull, background: .blue) }
		public static var onMagenta: Color	{ return Color(.dull, background: .magenta) }
		public static var onCyan: Color		{ return Color(.dull, background: .cyan) }
		public static var onWhite: Color	{ return Color(.dull, background: .white) }
		
		public static var vividBlack: Color		{ return Color(.vivid, foreground: .black) }
		public static var vividRed: Color		{ return Color(.vivid, foreground: .red) }
		public static var vividGreen: Color		{ return Color(.vivid, foreground: .green) }
		public static var vividYellow: Color	{ return Color(.vivid, foreground: .yellow) }
		public static var vividBlue: Color		{ return Color(.vivid, foreground: .blue) }
		public static var vividMagenta: Color	{ return Color(.vivid, foreground: .magenta) }
		public static var vividCyan: Color		{ return Color(.vivid, foreground: .cyan) }
		public static var vividWhite: Color		{ return Color(.vivid, foreground: .white) }
		
		public static var onVividBlack: Color	{ return Color(.vivid, background: .black) }
		public static var onVividRed: Color		{ return Color(.vivid, background: .red) }
		public static var onVividGreen: Color	{ return Color(.vivid, background: .green) }
		public static var onVividYellow: Color	{ return Color(.vivid, background: .yellow) }
		public static var onVividBlue: Color	{ return Color(.vivid, background: .blue) }
		public static var onVividMagenta: Color	{ return Color(.vivid, background: .magenta) }
		public static var onVividCyan: Color	{ return Color(.vivid, background: .cyan) }
		public static var onVividWhite: Color	{ return Color(.vivid, background: .white) }
		
		public var codes: [UInt8] {
			switch color {
			case let .plain(info):
				let layerCode: UInt8 = layer == .foreground ? 0 : 10
				let intensityCode: UInt8 = info.intensity == .dull ? 0 : 60
				return [info.color.rawValue + layerCode + intensityCode]
			
			case let .custom(info):
				let layerCode: UInt8 = layer == .foreground ? 38 : 48
				switch info {
				case let .custom(x):
					return [layerCode, 5, x]
				case let .rgb(r, g, b):
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
	case let (.rgb(lr, lg, lb), .rgb(rr, rg, rb)):
		return lr == rr && lg == rg && lb == rb
	case let (.custom(l), .custom(r)):
		return l == r
	default:
		return false
	}
}

public func == (lhs: DocumentStyle.Color.ColorInfo, rhs: DocumentStyle.Color.ColorInfo) -> Bool {
	switch (lhs, rhs) {
	case let (.plain(l), .plain(r)):
		return l == r
	case let (.custom(l), .custom(r)):
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
