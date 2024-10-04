import 'pdfdata.dart';
import 'youtube.dart';

class ModelFactory {
  static dynamic createModel(String modelName, Map<String, dynamic> data) {
    switch (modelName) {
      case 'pdfdata':
        return PdfData.fromJson(data);
      case 'youtubevideodata':
        return YoutubeData.fromJson(data);
      default:
        throw Exception('Model not found');
    }
  }
}

abstract class BaseModel {
  factory BaseModel.fromData(String modelName, Map<String, dynamic> data) {
    switch (modelName) {
      case 'pdfdata':
        return PdfData.fromJson(data);
      case 'youtubedata':
        return YoutubeData.fromJson(data);
      default:
        throw Exception('Model not found');
    }
  }
  static String getSearchTerm() => "";
}
