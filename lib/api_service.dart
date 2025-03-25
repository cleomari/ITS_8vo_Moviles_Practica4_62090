import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final String _apiUrl = dotenv.get('API_URL');

  // Obtener headers con token
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Login
  static Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': email, 'password': password}),
    );

    print('Login status: ${response.statusCode}');
    print('Respuesta del backend: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token'];
    } else {
      return null;
    }
  }


  // Registro
  static Future<bool> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': email, 'password': password}),
    );

    print('Registro status: ${response.statusCode}');
    print('Respuesta del backend: ${response.body}');

    return response.statusCode == 200 || response.statusCode == 201;
  }


  // Obtener todas las tareas
  static Future<List<Map<String, dynamic>>> getTasks() async {
    final response = await http.get(
      Uri.parse('$_apiUrl/tareas'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Error al cargar las tareas');
    }
  }

  // Obtener una tarea por ID
  static Future<Map<String, dynamic>> getTaskById(int id) async {
    final response = await http.get(
      Uri.parse('$_apiUrl/tareas/$id'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al cargar la tarea');
    }
  }

  // Crear una nueva tarea
  static Future<Map<String, dynamic>> createTask(Map<String, dynamic> task) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/tareas'),
      headers: await _getAuthHeaders(),
      body: json.encode(task),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al crear la tarea');
    }
  }

  // Actualizar una tarea
  static Future<Map<String, dynamic>> updateTask(int id, Map<String, dynamic> task) async {
    final response = await http.put(
      Uri.parse('$_apiUrl/tareas/$id'),
      headers: await _getAuthHeaders(),
      body: json.encode(task),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al actualizar la tarea');
    }
  }

  // Marcar una tarea como completada
  static Future<Map<String, dynamic>> toggleTaskCompletion(int id, bool completed) async {
    final response = await http.patch(
      Uri.parse('$_apiUrl/tareas/$id'),
      headers: await _getAuthHeaders(),
      body: json.encode({'completada': completed}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al actualizar la tarea');
    }
  }

  //  Eliminar una tarea
  static Future<void> deleteTask(int id) async {
    final response = await http.delete(
      Uri.parse('$_apiUrl/tareas/$id'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar la tarea');
    }
  }
}
