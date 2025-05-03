import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:open_filex/open_filex.dart';
import 'package:logging/logging.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FileViewerScreen extends StatefulWidget {
  final File file;

  const FileViewerScreen({super.key, required this.file});

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  VideoPlayerController? _videoController;
  late PdfViewerController _pdfViewerController;
  final List<NoteHighlight> highlights = [];
  final Logger _logger = Logger('FileViewerScreen');
  late String uploadedFileUrl;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();

    final filePath = widget.file.path.toLowerCase();
    if (_isVideo(filePath)) {
      _initializeVideoPlayer();
    }

    uploadedFileUrl = ''; // Initially empty, you can update this after file upload
    _uploadFileAndGetUrl();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  bool _isImage(String path) =>
      path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png');

  bool _isPdf(String path) => path.endsWith('.pdf');

  bool _isVideo(String path) =>
      path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.avi');

  bool _isOfficeDoc(String path) =>
      path.endsWith('.doc') || path.endsWith('.docx') || path.endsWith('.ppt') || path.endsWith('.pptx');

  void _initializeVideoPlayer() {
    _videoController = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
        _videoController!.play();
      }).catchError((error) {
        _logger.severe('Video initialization failed: $error');
      });
  }

  void _uploadFileAndGetUrl() async {
    final uploadedUrl = await _uploadFileToStorage(widget.file);
    setState(() {
      uploadedFileUrl = uploadedUrl; // Update the URL after file upload
    });
  }

  Future<String> _uploadFileToStorage(File file) async {
    return Future.delayed(Duration(seconds: 2), () {
      return 'https://your-public-file-url.com/${file.path.split('/').last}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final filePath = widget.file.path.toLowerCase();

    // Content widget based on file type
    Widget content = _buildFileContent(filePath);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.path.split('/').last),
        backgroundColor: Colors.brown,
      ),
      body: Stack(
        children: [
          content,
          ..._buildNoteWidgets(), // Display notes on top of content
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => _showAddNoteDialog(Offset(100, 100)), // Pass an initial position
              backgroundColor: Colors.brown,
              child: const Icon(Icons.note_add),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildFileContent(String filePath) {
  if (_isImage(filePath)) {
    return Scaffold(
      body: Center(
        child: InteractiveViewer(
          panEnabled: true, // Allow image to be dragged
          minScale: 0.1, // Zoom out to 10% of the original size
          maxScale: 4.0, // Zoom in to 400% of the original size
          boundaryMargin: EdgeInsets.all(20), // Extra space for panning beyond the container
          child: Container(
            width: double.infinity, // Allow the container to take full width of the screen
            height: double.infinity, // Allow the container to take full height of the screen
            decoration: BoxDecoration(
             
              borderRadius: BorderRadius.circular(10), // Optional: Round the corners of the border
            ),
            child: Image.file(
              widget.file,
              fit: BoxFit.contain, // Keep aspect ratio intact
            ),
          ),
        ),
      ),
    );
  } else if (_isPdf(filePath)) {
    return SfPdfViewer.file(widget.file, controller: _pdfViewerController);
  } else if (_isVideo(filePath) && _videoController != null && _videoController!.value.isInitialized) {
    return Center(
      child: Stack(
        alignment: Alignment.center, // Center the video and play button
        children: [
          VideoPlayer(_videoController!),
          IconButton(
            icon: Icon(Icons.play_arrow, size: 60, color: Colors.white),
            onPressed: () {
              if (_videoController!.value.isPlaying) {
                _videoController!.pause();
              } else {
                _videoController!.play();
              }
            },
          ),
        ],
      ),
    );
  } else if (_isOfficeDoc(filePath)) {
    return _buildOfficeFilePreview();
  } else {
    return _buildUnsupportedFilePreview();
  }
}

  Widget _buildOfficeFilePreview() {
    if (uploadedFileUrl.isEmpty) {
      return Center(child: Text("File URL is not available."));
    }

    final filePath = widget.file.path.toLowerCase();

    if (filePath.endsWith('.doc') || filePath.endsWith('.docx')) {
      return FutureBuilder<File>(
        future: _convertDocToPdf(widget.file),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return SfPdfViewer.file(snapshot.data!);
          } else {
            return Center(child: Text("Conversion failed."));
          }
        },
      );
    }

    final fileUrl = Uri.encodeFull(uploadedFileUrl);
    return WebViewWidget(
      controller: WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse('https://docs.google.com/viewer?url=$fileUrl&embedded=true')),
    );
  }

  Future<File> _convertDocToPdf(File docFile) async {
    throw UnimplementedError("Word to PDF conversion requires backend or Syncfusion Office add-on.");
  }

  Widget _buildUnsupportedFilePreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.insert_drive_file, size: 80, color: Colors.grey),
        const SizedBox(height: 20),
        const Text("Preview not supported for this file type."),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => OpenFilex.open(widget.file.path),
          child: const Text("Open with external app"),
        ),
      ],
    );
  }

  List<Widget> _buildNoteWidgets() {
    return highlights.map((highlight) {
      return Positioned(
        top: highlight.position.dy,
        left: highlight.position.dx,
        child: Draggable(
          feedback: _buildNoteBox(highlight, true),
          childWhenDragging: Container(),
          onDragEnd: (details) {
            setState(() {
              highlight.position = details.offset;
            });
          },
          child: GestureDetector(
            onTap: () => _showNoteDialog(highlight),

            child: _buildNoteBox(highlight, false),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildNoteBox(NoteHighlight highlight, bool isDragging) {
    return Container(
      width: highlight.width,
      height: highlight.height,
      decoration: BoxDecoration(
        color: highlight.color.withValues(alpha: (highlight.color.a * 0.7).toDouble()),
        border: Border.all(color: Colors.black54),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              highlight.note,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!isDragging)
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    highlight.width += details.delta.dx;
                    highlight.height += details.delta.dy;
                    if (highlight.width < 50) highlight.width = 50;
                    if (highlight.height < 30) highlight.height = 30;
                  });
                },
                child: const Icon(Icons.crop_square, size: 18, color: Colors.white70),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(Offset position) {
    TextEditingController noteController = TextEditingController();
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Enter note text'),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _colorCircle(Colors.blue, selectedColor, (color) {
                    setState(() => selectedColor = color);
                  }),
                  _colorCircle(Colors.green, selectedColor, (color) {
                    setState(() => selectedColor = color);
                  }),
                  _colorCircle(Colors.red, selectedColor, (color) {
                    setState(() => selectedColor = color);
                  }),
                  _colorCircle(Colors.orange, selectedColor, (color) {
                    setState(() => selectedColor = color);
                  }),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (noteController.text.isNotEmpty) {
                  setState(() {
                    highlights.add(
                      NoteHighlight(
                        note: noteController.text,
                        color: selectedColor,
                        position: position,
                      ),
                    );
                    _logger.info('Note added: ${noteController.text} at $position');
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

void _showNoteDialog(NoteHighlight highlight) {
  TextEditingController noteController = TextEditingController(text: highlight.note);
  Color selectedColor = highlight.color;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Note'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: noteController,
            decoration: const InputDecoration(labelText: 'Edit note text'),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _colorCircle(Colors.blue, selectedColor, (color) {
                setState(() {
                  selectedColor = color;
                });
              }),
              _colorCircle(Colors.green, selectedColor, (color) {
                setState(() {
                  selectedColor = color;
                });
              }),
              _colorCircle(Colors.red, selectedColor, (color) {
                setState(() {
                  selectedColor = color;
                });
              }),
              _colorCircle(Colors.orange, selectedColor, (color) {
                setState(() {
                  selectedColor = color;
                });
              }),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Remove note
            setState(() {
              highlights.remove(highlight);
            });
            Navigator.pop(context);
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              highlight.note = noteController.text;
              highlight.color = selectedColor;
            });
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

  Widget _colorCircle(Color color, Color selected, void Function(Color) onTap) {
    return GestureDetector(
      onTap: () {
        setState(() {
          onTap(color);
        });
      },
      child: CircleAvatar(
        backgroundColor: color,
        radius: 15,
        child: selected == color ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
      ),
    );
  }
}

class NoteHighlight {
  String note;
  Color color;
  Offset position;
  double width = 100;
  double height = 50;

  NoteHighlight({
    required this.note,
    required this.color,
    required this.position,
  });
}


