public class DentalColorScales {
    
    // Klasa reprezentująca pojedynczy kolor dentystyczny
    public static class DentalColor {
        private final String scaleType;  // Typ skali (VITA A-D, 3D Master, Chromascope)
        private final String colorCode;  // Kod koloru (np. A1, 3M2, 240)
        private final int[] rgb;         // Wartości RGB (red, green, blue)
        private final double[] lab;      // Wartości CIELAB (L*, a*, b*)
        
        public DentalColor(String scaleType, String colorCode, int[] rgb, double[] lab) {
            this.scaleType = scaleType;
            this.colorCode = colorCode;
            this.rgb = rgb;
            this.lab = lab;
        }
        
        public String getScaleType() {
            return scaleType;
        }
        
        public String getColorCode() {
            return colorCode;
        }
        
        public int[] getRgb() {
            return rgb;
        }
        
        public double[] getLab() {
            return lab;
        }
        
        @Override
        public String toString() {
            return String.format("%s %s: RGB(%d,%d,%d), L*=%.1f, a*=%.1f, b*=%.1f", 
                    scaleType, colorCode, rgb[0], rgb[1], rgb[2], lab[0], lab[1], lab[2]);
        }
    }
    
    // Główna tablica zawierająca wszystkie kolory dentystyczne
    public static final DentalColor[] DENTAL_COLORS = {
        // VITA Classical A-D
        new DentalColor("VITA-A-D", "A1", new int[]{242, 222, 194}, new double[]{86.0, 1.0, 18.0}),
        new DentalColor("VITA-A-D", "A2", new int[]{238, 213, 183}, new double[]{84.0, 2.0, 21.0}),
        new DentalColor("VITA-A-D", "A3", new int[]{233, 204, 167}, new double[]{82.0, 3.0, 25.0}),
        new DentalColor("VITA-A-D", "A3.5", new int[]{226, 193, 153}, new double[]{79.0, 4.0, 27.0}),
        new DentalColor("VITA-A-D", "A4", new int[]{215, 177, 137}, new double[]{75.0, 5.0, 29.0}),
        new DentalColor("VITA-A-D", "B1", new int[]{245, 227, 197}, new double[]{88.0, 0.0, 16.0}),
        new DentalColor("VITA-A-D", "B2", new int[]{236, 216, 186}, new double[]{85.0, 0.0, 19.0}),
        new DentalColor("VITA-A-D", "B3", new int[]{229, 203, 168}, new double[]{82.0, 1.0, 23.0}),
        new DentalColor("VITA-A-D", "B4", new int[]{219, 190, 148}, new double[]{78.0, 2.0, 25.0}),
        new DentalColor("VITA-A-D", "C1", new int[]{234, 214, 184}, new double[]{84.0, 0.0, 16.0}),
        new DentalColor("VITA-A-D", "C2", new int[]{227, 202, 169}, new double[]{81.0, 1.0, 18.0}),
        new DentalColor("VITA-A-D", "C3", new int[]{217, 189, 154}, new double[]{77.0, 2.0, 20.0}),
        new DentalColor("VITA-A-D", "C4", new int[]{205, 173, 137}, new double[]{73.0, 3.0, 22.0}),
        new DentalColor("VITA-A-D", "D2", new int[]{229, 205, 172}, new double[]{82.0, 1.0, 17.0}),
        new DentalColor("VITA-A-D", "D3", new int[]{223, 193, 156}, new double[]{79.0, 2.0, 19.0}),
        new DentalColor("VITA-A-D", "D4", new int[]{215, 184, 145}, new double[]{75.0, 3.0, 21.0}),
        
        // VITA 3D-Master
        new DentalColor("VITA-3D", "0M1", new int[]{252, 238, 213}, new double[]{92.0, 0.0, 14.0}),
        new DentalColor("VITA-3D", "0M2", new int[]{246, 230, 202}, new double[]{90.0, 0.0, 16.0}),
        new DentalColor("VITA-3D", "0M3", new int[]{241, 223, 192}, new double[]{87.0, 0.0, 18.0}),
        new DentalColor("VITA-3D", "1M1", new int[]{244, 227, 198}, new double[]{89.0, 0.0, 16.0}),
        new DentalColor("VITA-3D", "1M2", new int[]{239, 219, 187}, new double[]{86.0, 1.0, 18.0}),
        new DentalColor("VITA-3D", "2L1.5", new int[]{237, 215, 183}, new double[]{85.0, 1.0, 18.0}),
        new DentalColor("VITA-3D", "2L2.5", new int[]{232, 205, 170}, new double[]{82.0, 2.0, 20.0}),
        new DentalColor("VITA-3D", "2M1", new int[]{236, 217, 187}, new double[]{85.0, 0.0, 17.0}),
        new DentalColor("VITA-3D", "2M2", new int[]{232, 208, 173}, new double[]{83.0, 1.0, 20.0}),
        new DentalColor("VITA-3D", "2M3", new int[]{228, 199, 160}, new double[]{81.0, 2.0, 22.0}),
        new DentalColor("VITA-3D", "2R1.5", new int[]{235, 212, 177}, new double[]{84.0, 2.0, 19.0}),
        new DentalColor("VITA-3D", "2R2.5", new int[]{230, 202, 164}, new double[]{81.0, 3.0, 22.0}),
        new DentalColor("VITA-3D", "3L1.5", new int[]{225, 201, 165}, new double[]{80.0, 2.0, 20.0}),
        new DentalColor("VITA-3D", "3L2.5", new int[]{220, 191, 150}, new double[]{77.0, 3.0, 22.0}),
        new DentalColor("VITA-3D", "3M1", new int[]{224, 203, 167}, new double[]{81.0, 1.0, 19.0}),
        new DentalColor("VITA-3D", "3M2", new int[]{220, 193, 155}, new double[]{78.0, 2.0, 21.0}),
        new DentalColor("VITA-3D", "3M3", new int[]{214, 185, 143}, new double[]{75.0, 3.0, 24.0}),
        new DentalColor("VITA-3D", "3R1.5", new int[]{223, 196, 157}, new double[]{79.0, 3.0, 21.0}),
        new DentalColor("VITA-3D", "3R2.5", new int[]{217, 187, 145}, new double[]{76.0, 4.0, 24.0}),
        new DentalColor("VITA-3D", "4L1.5", new int[]{213, 188, 149}, new double[]{76.0, 2.0, 21.0}),
        new DentalColor("VITA-3D", "4L2.5", new int[]{207, 178, 137}, new double[]{72.0, 3.0, 24.0}),
        new DentalColor("VITA-3D", "4M1", new int[]{211, 186, 147}, new double[]{75.0, 2.0, 22.0}),
        new DentalColor("VITA-3D", "4M2", new int[]{205, 177, 134}, new double[]{72.0, 3.0, 25.0}),
        new DentalColor("VITA-3D", "4M3", new int[]{200, 168, 126}, new double[]{69.0, 4.0, 27.0}),
        new DentalColor("VITA-3D", "4R1.5", new int[]{210, 181, 139}, new double[]{74.0, 3.0, 23.0}),
        new DentalColor("VITA-3D", "4R2.5", new int[]{204, 172, 127}, new double[]{71.0, 4.0, 26.0}),
        new DentalColor("VITA-3D", "5M1", new int[]{197, 171, 131}, new double[]{70.0, 2.0, 24.0}),
        new DentalColor("VITA-3D", "5M2", new int[]{192, 163, 120}, new double[]{67.0, 3.0, 26.0}),
        new DentalColor("VITA-3D", "5M3", new int[]{186, 153, 110}, new double[]{63.0, 4.0, 28.0}),
        
        // Ivoclar Chromascope
        new DentalColor("Chromascope", "110", new int[]{249, 234, 208}, new double[]{91.0, 0.0, 15.0}),
        new DentalColor("Chromascope", "120", new int[]{244, 228, 200}, new double[]{89.0, 0.0, 16.0}),
        new DentalColor("Chromascope", "130", new int[]{239, 221, 190}, new double[]{87.0, 1.0, 18.0}),
        new DentalColor("Chromascope", "140", new int[]{233, 214, 180}, new double[]{84.0, 1.0, 19.0}),
        new DentalColor("Chromascope", "210", new int[]{241, 223, 186}, new double[]{87.0, 0.0, 20.0}),
        new DentalColor("Chromascope", "220", new int[]{236, 216, 177}, new double[]{85.0, 1.0, 22.0}),
        new DentalColor("Chromascope", "230", new int[]{231, 209, 168}, new double[]{83.0, 2.0, 24.0}),
        new DentalColor("Chromascope", "240", new int[]{226, 201, 157}, new double[]{80.0, 3.0, 26.0}),
        new DentalColor("Chromascope", "310", new int[]{237, 214, 175}, new double[]{84.0, 2.0, 22.0}),
        new DentalColor("Chromascope", "320", new int[]{232, 206, 165}, new double[]{82.0, 3.0, 24.0}),
        new DentalColor("Chromascope", "330", new int[]{227, 198, 155}, new double[]{79.0, 4.0, 26.0}),
        new DentalColor("Chromascope", "340", new int[]{221, 189, 143}, new double[]{76.0, 5.0, 28.0}),
        new DentalColor("Chromascope", "410", new int[]{231, 210, 179}, new double[]{83.0, 1.0, 18.0}),
        new DentalColor("Chromascope", "420", new int[]{225, 201, 169}, new double[]{80.0, 2.0, 20.0}),
        new DentalColor("Chromascope", "430", new int[]{219, 192, 158}, new double[]{77.0, 3.0, 22.0}),
        new DentalColor("Chromascope", "440", new int[]{212, 183, 146}, new double[]{74.0, 4.0, 24.0}),
        new DentalColor("Chromascope", "510", new int[]{223, 196, 160}, new double[]{78.0, 3.0, 22.0}),
        new DentalColor("Chromascope", "520", new int[]{217, 187, 149}, new double[]{75.0, 4.0, 24.0}),
        new DentalColor("Chromascope", "530", new int[]{211, 178, 138}, new double[]{72.0, 5.0, 26.0}),
        new DentalColor("Chromascope", "540", new int[]{204, 168, 126}, new double[]{69.0, 6.0, 28.0})
    };
    
    // Metoda do wyszukiwania kolorów według skali
    public static DentalColor[] findColorsByScale(String scaleType) {
        return Arrays.stream(DENTAL_COLORS)
                .filter(color -> color.getScaleType().equals(scaleType))
                .toArray(DentalColor[]::new);
    }
    
    // Metoda do wyszukiwania konkretnego koloru po skali i kodzie
    public static DentalColor findColor(String scaleType, String colorCode) {
        return Arrays.stream(DENTAL_COLORS)
                .filter(color -> color.getScaleType().equals(scaleType) && color.getColorCode().equals(colorCode))
                .findFirst()
                .orElse(null);
    }
    
    // Metoda do znalezienia najbliższego koloru na podstawie wartości RGB
    public static DentalColor findClosestColorByRgb(int[] targetRgb) {
        DentalColor closest = null;
        double minDistance = Double.MAX_VALUE;
        
        for (DentalColor color : DENTAL_COLORS) {
            double distance = calculateRgbDistance(targetRgb, color.getRgb());
            if (distance < minDistance) {
                minDistance = distance;
                closest = color;
            }
        }
        
        return closest;
    }
    
    // Metoda do znalezienia najbliższego koloru na podstawie wartości CIELAB
    public static DentalColor findClosestColorByLab(double[] targetLab) {
        DentalColor closest = null;
        double minDistance = Double.MAX_VALUE;
        
        for (DentalColor color : DENTAL_COLORS) {
            double distance = calculateLabDistance(targetLab, color.getLab());
            if (distance < minDistance) {
                minDistance = distance;
                closest = color;
            }
        }
        
        return closest;
    }
    
    // Obliczanie odległości euklidesowej w przestrzeni RGB
    private static double calculateRgbDistance(int[] rgb1, int[] rgb2) {
        return Math.sqrt(
                Math.pow(rgb1[0] - rgb2[0], 2) +
                Math.pow(rgb1[1] - rgb2[1], 2) +
                Math.pow(rgb1[2] - rgb2[2], 2)
        );
    }
    
    // Obliczanie odległości euklidesowej w przestrzeni CIELAB (ΔE)
    private static double calculateLabDistance(double[] lab1, double[] lab2) {
        return Math.sqrt(
                Math.pow(lab1[0] - lab2[0], 2) +
                Math.pow(lab1[1] - lab2[1], 2) +
                Math.pow(lab1[2] - lab2[2], 2)
        );
    }
    
    // Przykład użycia
    public static void main(String[] args) {
        // Wypisanie wszystkich kolorów VITA A-D
        System.out.println("VITA Classical A-D Colors:");
        for (DentalColor color : findColorsByScale("VITA-A-D")) {
            System.out.println(color);
        }
        
        // Znalezienie określonego koloru
        DentalColor a3 = findColor("VITA-A-D", "A3");
        if (a3 != null) {
            System.out.println("\nFound color: " + a3);
        }
        
        // Przykład znajdowania najbliższego koloru do podanego RGB
        int[] sampleRgb = {230, 205, 165};
        DentalColor closestByRgb = findClosestColorByRgb(sampleRgb);
        System.out.println("\nClosest color to RGB(230,205,165): " + closestByRgb);
        
        // Przykład znajdowania najbliższego koloru do podanego CIELAB
        double[] sampleLab = {80.0, 2.0, 22.0};
        DentalColor closestByLab = findClosestColorByLab(sampleLab);
        System.out.println("\nClosest color to L*=80, a*=2, b*=22: " + closestByLab);
    }
}
