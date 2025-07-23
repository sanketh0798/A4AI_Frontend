import 'dart:io';
import 'package:a4ai_ui/screen/loginScreen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';




class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}
final storage = FlutterSecureStorage();

class _HomePageScreenState extends State<HomePageScreen> {
  final AudioRecorder audioRecorder = AudioRecorder();
  final TextEditingController gradeController = TextEditingController();
  bool isRecording = false;
  String? recordedFilePath;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('A4AI', style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: Colors.blue,
      ),
      
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0), 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to the Home Page',
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),

              ],
            ),
           
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: gradeController,
              decoration: InputDecoration(
                labelText: 'Grade',
                border: OutlineInputBorder(),
              ),
            )
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Click the mic button to record your voice',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                _recordingButton(context),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('Answer : ${recordedFilePath}', style: TextStyle(fontSize: 20), 
              overflow: TextOverflow.visible,
              softWrap: true,)],
              
            ),
          ),
        ]


    )
    );
  }

  Widget _recordingButton(BuildContext context) {
  return FloatingActionButton(
    backgroundColor: isRecording ? Colors.red : Colors.green,
    tooltip: isRecording ? 'Stop Recording' : 'Start Recording',
    child: Icon(isRecording ? Icons.stop : Icons.mic),
    onPressed: () async {
      if (isRecording) {
        // STOP recording
        try {
          String? filepath = await audioRecorder.stop();
          if (filepath != null) {
            setState(() {
              isRecording = false;
              recordedFilePath = filepath;
            });
            print('Recording stopped. File saved at: $filepath');
            await getVoiceAssistance(context, recordedFilePath);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No file generated')),
            );
            setState(() => isRecording = false);
          }
        } catch (e) {
          print('Error stopping recording: $e');
        }
      } else {
        // START recording
        try {
          if (await audioRecorder.hasPermission()) {
            final Directory appDocDir = await getApplicationDocumentsDirectory();
            final String filePath = p.join(appDocDir.path, 'recording.wav');

            // Optional: Delete existing file (if required)
            final file = File(filePath);
            if (file.existsSync()) file.deleteSync();

            await audioRecorder.start(const RecordConfig(), path: filePath);
            setState(() {
              isRecording = true;
              recordedFilePath = null; // Reset old file path
            });
            print('Recording started...');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Microphone permission denied')),
            );
          }
        } catch (e) {
          print('Error starting recording: $e');
        }
      }
    },
  );
}

 
}
Future <void> getVoiceAssistance(BuildContext context, String? recordedFilePath) async {
  
  // 1. Read stored user info
  final LoginResponsejsonString = await storage.read(key: 'user'); // Retrieve user data from secure storage
  
  // Check if LoginResponsejsonString is not null
  if (LoginResponsejsonString == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User data not found'),
        backgroundColor: Colors.red,
      ),
    );
    return; //Stop further execution
  }

  // Decode the JSON string to get user data. now its string and not string?. its verified that is not null
  final userdata = jsonDecode(LoginResponsejsonString);
  final String uid = userdata['user_data']['uid'];
  final String idToken = userdata['tokens']['id_token'];
  
  // Check if recordedFilePath is not null
  if (recordedFilePath != null && recordedFilePath.isNotEmpty) {
    if (LoginResponsejsonString != null) {
      
      String recordedFilePathstr = recordedFilePath ?? "Guest"; // Fallback if no recording is available
      
      // 2. Attach the token as a QUERY parameter
      final url = Uri.parse('http://10.0.2.2:8000/api/v1/voice/assistant?token=$idToken');

      // 3. Create a multipart request
      var request = http.MultipartRequest('POST', url);
      // request.headers['token'] = idToken; // another unconfirmed way to pass token
      request.fields['user_id'] = uid; // Add the user ID to the request fields. must match API's expected field name!
      request.files.add(await http.MultipartFile.fromPath('audio_file', recordedFilePathstr)); // 'audio_file' must match the API's expected field name
      
      try {
        var response = await request.send();
        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          print('API Success: $responseBody');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Audio uploaded successfully')),
          );
        } else {
          final errorresponsebody = await response.stream.bytesToString();
          print('API Error: $errorresponsebody');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('API failed: $errorresponsebody')),
          );
        }
      } on Exception catch (e) {
        print('Exception: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exception occurred: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User data not found'),
          backgroundColor: Colors.red,
        )
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No recording available'),
        backgroundColor: Colors.red,
      ),
    );
    
  }

  

  
  
}

