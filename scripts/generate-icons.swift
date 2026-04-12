#!/usr/bin/swift
// Siturem — App Icon Generator
// Reproduit le motif SituremMark (3 capsules centrées) sur fond anthracite.
// Usage : swift scripts/generate-icons.swift  (depuis la racine du repo)

import Foundation
import CoreGraphics
import ImageIO

// MARK: - Couleurs (identiques à Theme.swift)
// background : #181820  accent : #6E7FA3

let bgRed:   CGFloat = 0.094;  let bgGreen: CGFloat = 0.094;  let bgBlue:  CGFloat = 0.118
let acRed:   CGFloat = 0.431;  let acGreen: CGFloat = 0.498;  let acBlue:  CGFloat = 0.639

// MARK: - Proportions du motif (relatives à la taille de l'icône)
// La barre de méditation (100 %) occupe 50 % de la largeur de l'icône.
let markWidthRatio: CGFloat = 0.50
let barHeightRatio: CGFloat = 0.048   // hauteur de chaque capsule
let gapRatio:       CGFloat = 0.070   // espace inter-capsule

// Trois capsules : intro, méditation, closing
let barRatios:    [CGFloat] = [0.55, 1.00, 0.30]
let barOpacities: [CGFloat] = [0.70, 1.00, 0.45]

// MARK: - Génération d'un PNG

func renderIcon(size: Int, path: String) {
    let s = CGFloat(size)
    let space = CGColorSpaceCreateDeviceRGB()

    guard let ctx = CGContext(
        data: nil, width: size, height: size,
        bitsPerComponent: 8, bytesPerRow: 0,
        space: space,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        print("Erreur : impossible de créer le contexte pour \(size)px")
        return
    }

    // Repère : Y=0 en haut (flip vertical)
    ctx.translateBy(x: 0, y: s)
    ctx.scaleBy(x: 1, y: -1)

    // Fond
    ctx.setFillColor(red: bgRed, green: bgGreen, blue: bgBlue, alpha: 1.0)
    ctx.fill(CGRect(x: 0, y: 0, width: s, height: s))

    // Géométrie du motif
    let markFullWidth = s * markWidthRatio
    let barH  = max(2.0, s * barHeightRatio)
    let gap   = max(1.0, s * gapRatio)
    let totalH = 3 * barH + 2 * gap

    let originY = (s - totalH) / 2.0   // Y visuel du bord supérieur de la 1re barre

    for i in 0..<3 {
        let barWidth = markFullWidth * barRatios[i]
        let barX     = (s - barWidth) / 2.0             // centré horizontalement
        let barY     = originY + CGFloat(i) * (barH + gap)

        ctx.setFillColor(red: acRed, green: acGreen, blue: acBlue, alpha: barOpacities[i])

        let rect   = CGRect(x: barX, y: barY, width: barWidth, height: barH)
        let radius = barH / 2.0
        let capsule = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
        ctx.addPath(capsule)
        ctx.fillPath()
    }

    guard let image = ctx.makeImage() else {
        print("Erreur : impossible de créer l'image pour \(size)px")
        return
    }

    let url = URL(fileURLWithPath: path)
    guard let dest = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil) else {
        print("Erreur : impossible d'ouvrir la destination \(path)")
        return
    }
    CGImageDestinationAddImage(dest, image, nil)
    CGImageDestinationFinalize(dest)
    print("✓ \(path) (\(size)×\(size) px)")
}

// MARK: - Tailles à produire

let outputDir = "Siturem/Resources/Assets.xcassets/AppIcon.appiconset"

let targets: [(Int, String)] = [
    (120,  "icon-120.png"),
    (152,  "icon-152.png"),
    (167,  "icon-167.png"),
    (180,  "icon-180.png"),
    (1024, "icon-1024.png")
]

for (size, filename) in targets {
    renderIcon(size: size, path: "\(outputDir)/\(filename)")
}

print("\nIcones générées dans \(outputDir)/")
