import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import '../services/meal_model.dart';

class PDFService {
  static Future<String?> generateNutritionReport({
    required dynamic result,
    required List<MealModel> meals,
    required String userName,
  }) async {
    final now = DateTime.now();
    final dateStr = '${now.day}-${now.month}-${now.year}';
    final timeStr = '${now.hour}:${now.minute}:${now.second}';

    // Calculate totals
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (var meal in meals) {
      totalCalories += double.parse(meal.calories);
      totalProtein += double.parse(meal.protein);
      totalCarbs += double.parse(meal.carbs);
      totalFats += double.parse(meal.fat);
    }

    // Create PDF document
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header
          pw.Center(
            child: pw.Text(
              'Nutrition Analysis Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          
          // User Info
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('User Name: $userName', style: pw.TextStyle(fontSize: 12)),
                pw.Text('Date: $dateStr', style: pw.TextStyle(fontSize: 12)),
                pw.Text('Time: $timeStr', style: pw.TextStyle(fontSize: 12)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // BMI Section
          pw.Text(
            'Body Mass Index (BMI)',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'BMI Value',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Category',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(result.bmi.toStringAsFixed(1)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(result.bmiCategory),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Daily Needs Section
          pw.Text(
            'Daily Nutritional Requirements',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'TDEE (Calories)',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'BMR (Calories)',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(result.tdee.toStringAsFixed(0)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(result.bmr.toStringAsFixed(0)),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Macros Section
          pw.Text(
            'Macronutrient Distribution',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Carbs (g)',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Protein (g)',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Fats (g)',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(result.macros.carbs.toStringAsFixed(0)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(result.macros.protein.toStringAsFixed(0)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(result.macros.fats.toStringAsFixed(0)),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Meals Section
          if (meals.isNotEmpty) ...[
            pw.Text(
              'Meals Added Today',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Meal Name',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Calories',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Protein (g)',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...meals.map((meal) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(meal.name),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(meal.calories),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(meal.protein),
                    ),
                  ],
                )),
              ],
            ),
            pw.SizedBox(height: 20),

            // Totals
            pw.Text(
              'Daily Totals',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Total Calories',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(totalCalories.toStringAsFixed(0)),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Total Protein (g)'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(totalProtein.toStringAsFixed(0)),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Total Carbs (g)'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(totalCarbs.toStringAsFixed(0)),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Total Fats (g)'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(totalFats.toStringAsFixed(0)),
                    ),
                  ],
                ),
              ],
            ),
          ] else ...[
            pw.Text('No meals added yet'),
          ],

          pw.SizedBox(height: 40),
          pw.Center(
            child: pw.Text(
              'Generated by Smart Nutrition App',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ),
        ],
      ),
    );

    // Save PDF to temp directory for WebView access
    return await _savePDF(pdf, 'nutrition_report_$dateStr-$timeStr.pdf');
  }

  static Future<String?> _savePDF(pw.Document pdf, String fileName) async {
    try {
      // Save to external cache directory for easier access
      Directory cacheDir = await getTemporaryDirectory();
      final file = File('${cacheDir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      print('PDF saved to: ${file.path}');
      return file.path;
    } catch (e) {
      print('Error saving PDF: $e');
      return null;
    }
  }

  static Future<String?> getReportPath() async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      return appDir.path;
    } catch (e) {
      return null;
    }
  }
}
