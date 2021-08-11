package r.hung;

import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;

import java.io.IOException;
import java.net.URI;
import java.net.URL;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Objects;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class WasGibtsHeutMain {

    public static final String JOSI = "https://jonathan-sieglinde.com/mittags-speiseplan/";
    private static final String FIFTEEN_SIXTEEN = "https://www.1516brewingcompany.com/daily-special/";
    private static final String ELISSAR = "https://www.elissar.at/wp-content/uploads/2017/09/mittagsmenu.pdf";
    private static final String MAMA_BULLE = "https://www.mamaundderbulle.at/";
    private static final String BETTELSTUDENT = "https://www.bettelstudent.at/";

    private static final String[] days = {"Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"};
    private static final String[] daysShort = {"SO", "MO", "DI", "MI", "DO", "FR", "SA", "SO"};

    public static void main(String[] args) throws IOException, InterruptedException {
        josi();
        fifteenSixteen();
        elissar();
        mamaBulle();
        bettelstudent();
    }

    private static void bettelstudent() throws IOException, InterruptedException {
        System.out.println("bettelstudent");
        String url = getPatternMatchGroup1(makeRequest(BETTELSTUDENT), "href=\"([^\"]*Wochenmenu.*?\\.pdf)");
        if (url != null) {
            int day = LocalDate.now().getDayOfWeek().getValue();
            String match = getPatternMatchGroup1(readPDF(BETTELSTUDENT + url), days[day] + "([\\s\\S]*?)(" + days[day + 1] + "|Alternative)");
            System.out.println(Objects.requireNonNullElse(match, "Nothing found :("));
        } else {
            System.out.println("Nothing found :(");
        }
        System.out.println();
    }

    private static void mamaBulle() throws IOException, InterruptedException {
        System.out.println("mama und der bulle");
        String match = getPatternMatchGroup1(makeRequest(MAMA_BULLE), "Speisekarte.*href=\"(.*?)\".*Mama.s Lunch Deal");
        if (match != null) {
            String text = readPDF(match);
            String[] lines = text.replaceAll("\\n\\s+", "\n").split("\\n");
            if (lines.length > 9) {
                int day = LocalDate.now().getDayOfWeek().getValue();
                System.out.println(lines[day * 2 - 1] + "\n" + lines[day * 2]);
            } else {
                System.out.println("Nothing found :(");
            }
        } else {
            System.out.println("Nothing found :(");
        }
        System.out.println();
    }

    private static void elissar() throws IOException {
        System.out.println("elissar");
        String text = readPDF(ELISSAR).replaceAll("\\s+", " ").replaceAll("Donner stag", "Donnerstag");
        int day = LocalDate.now().getDayOfWeek().getValue();
        String match = getPatternMatchGroup1(text, "Montag ?\\- ?Freitag.*?" + days[day] + ".*?(Men. I.*?Men. II.*?)(" + days[day + 1] + "|Johannesgasse)");
        System.out.println(Objects.requireNonNullElse(match, "Nothing found :("));
        System.out.println();
    }

    private static void fifteenSixteen() throws IOException, InterruptedException {
        System.out.println("1516");
        String match = getPatternMatchGroup1(makeRequest(FIFTEEN_SIXTEEN), LocalDate.now().format(DateTimeFormatter.ofPattern("dd.MM")) + "[\\s\\S]*?<strong>([\\s\\S]*?)</strong>");
        System.out.println(Objects.requireNonNullElse(match, "Nothing found :("));
        System.out.println();
    }

    private static void josi() throws IOException, InterruptedException {
        System.out.println("josi");
        String match = getPatternMatchGroup1(makeRequest(JOSI), "pdf-embedder url=&quot;(.*?)&quot;");
        if (match != null) {
            String weekText = getWeekText(readPDF(match));
            int day = LocalDate.now().getDayOfWeek().getValue();
            String weekMatch = getPatternMatchGroup1(weekText, daysShort[day] + "([\\s\\S]*?)" + daysShort[day + 1]);
            System.out.println(Objects.requireNonNullElse(weekMatch, "Nothing found :("));
        } else {
            System.out.println("Nothing found :(");
        }
        System.out.println();
    }

    private static String getWeekText(String text) {
        Pattern pattern = Pattern.compile("(\\d+)\\.(\\d+\\.)?[-–](\\d+)\\.\\d+([\\s\\S]+)");
        Matcher matcher = pattern.matcher(text);
        if (matcher.find()) {
            int day = LocalDate.now().getDayOfMonth();
            int first = Integer.parseInt(matcher.group(1));
            int third = Integer.parseInt(matcher.group(3));
            if (first < third) {
                if (day >= first && day <= third) {
                    return matcher.group(4);
                } else {
                    return getWeekText(matcher.group(4));
                }
            } else {
                if (day >= first || day <= third) {
                    return matcher.group(4);
                } else {
                    return getWeekText(matcher.group(4));
                }
            }
        }
        return null;
    }

    private static String getPatternMatchGroup1(String text, String patternText) {
        Pattern pattern = Pattern.compile(patternText);
        Matcher matcher = pattern.matcher(text);
        if (matcher.find()) {
            return matcher.group(1).trim();
        } else {
            return null;
        }
    }

    private static String readPDF(String url) throws IOException {
        PDDocument document = Loader.loadPDF(new URL(url).openStream());
        PDFTextStripper stripper = new PDFTextStripper();
        stripper.setSortByPosition(true);
        return stripper.getText(document).trim();
    }

    private static String makeRequest(String website) throws IOException, InterruptedException {
        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(website))
                .GET()
                .build();
        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        return response.body();
    }
}
