import java.io.*;
import java.util.*;

class ColorEntry {
    String shade;
    double L, a, b;

    public ColorEntry(String shade, double L, double a, double b) {
        this.shade = shade;
        this.L = L;
        this.a = a;
        this.b = b;
    }

    public double deltaE(ColorEntry other) {
        return Math.sqrt(Math.pow(this.L - other.L, 2) +
                         Math.pow(this.a - other.a, 2) +
                         Math.pow(this.b - other.b, 2));
    }
}

public class ColorMatcher {

    public static List<ColorEntry> loadColors(String filePath) throws IOException {
        List<ColorEntry> colors = new ArrayList<>();
        BufferedReader reader = new BufferedReader(new FileReader(filePath));
        String line;
        boolean header = true;

        while ((line = reader.readLine()) != null) {
            if (header) {
                header = false;
                continue;
            }
            String[] parts = line.split(",");
            String shade = parts[0];
            double L = Double.parseDouble(parts[4]);
            double a = Double.parseDouble(parts[5]);
            double b = Double.parseDouble(parts[6]);
            colors.add(new ColorEntry(shade, L, a, b));
        }
        reader.close();
        return colors;
    }

    public static ColorEntry findColor(List<ColorEntry> list, String shade) {
        for (ColorEntry entry : list) {
            if (entry.shade.equalsIgnoreCase(shade)) {
                return entry;
            }
        }
        return null;
    }

    public static List<ColorEntry> findClosest(ColorEntry target, List<ColorEntry> candidates, int topN) {
        List<ColorEntry> sorted = new ArrayList<>(candidates);
        sorted.sort(Comparator.comparingDouble(c -> target.deltaE(c)));
        return sorted.subList(0, Math.min(topN, sorted.size()));
    }

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        try {
            System.out.print("Podaj ścieżkę do pliku Vita Classical (A-D): ");
            String vitaADPath = scanner.nextLine();

            System.out.print("Podaj ścieżkę do pliku Ivoclar Chromascop: ");
            String chromascopPath = scanner.nextLine();

            System.out.print("Podaj ścieżkę do pliku Vita 3D-Master: ");
            String vita3dPath = scanner.nextLine();

            List<ColorEntry> vitaADColors = loadColors(vitaADPath);
            List<ColorEntry> chromascopColors = loadColors(chromascopPath);
            List<ColorEntry> vita3dColors = loadColors(vita3dPath);

            System.out.print("Podaj symbol koloru do wyszukania (np. A3): ");
            String inputShade = scanner.nextLine();

            ColorEntry selectedColor = findColor(vitaADColors, inputShade);

            if (selectedColor == null) {
                System.out.println("Nie znaleziono koloru " + inputShade + " w Vita Classical.");
                return;
            }

            List<ColorEntry> closestChromascop = findClosest(selectedColor, chromascopColors, 4);
            List<ColorEntry> closestVita3D = findClosest(selectedColor, vita3dColors, 4);

            System.out.println("\nNajbliższe kolory Chromascop:");
            for (ColorEntry c : closestChromascop) {
                System.out.printf("%s (DeltaE=%.2f)\n", c.shade, selectedColor.deltaE(c));
            }

            System.out.println("\nNajbliższe kolory Vita 3D-Master:");
            for (ColorEntry c : closestVita3D) {
                System.out.printf("%s (DeltaE=%.2f)\n", c.shade, selectedColor.deltaE(c));
            }

        } catch (IOException e) {
            System.out.println("Błąd podczas wczytywania pliku: " + e.getMessage());
        }
    }
}
