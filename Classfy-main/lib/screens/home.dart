import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart'; // 🔥 New import
import 'package:classfy/screens/calendar_page.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _currentFolder = '';
  final List<Map<String, String>> _items = [];
  String _searchQuery = '';

  void onItemTapped(int index) {
  if (index == 1) {
    // Navigate to the CalendarPage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CalendarPage()),
    );
  } else {
    setState(() {
      _selectedIndex = index;
    });
  }
}

 
  List<Map<String, String>> get filteredItems {
    if (_searchQuery.isEmpty) {
      return _items;
    }
    return _items.where((item) {
      return item['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['folder']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5E6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_currentFolder.isNotEmpty) {
              setState(() {
                _currentFolder = '';
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: CircleAvatar(
              backgroundColor: Colors.brown,
              radius: 18,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildImportButton(Icons.insert_drive_file, 'import\nFile', () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
                  );
                  if (result != null && result.files.single.path != null) {
                    _showNameInputDialog(result.files.single.name, result.files.single.path!);
                  }
                }),
                _buildImportButton(Icons.image, 'import\nimage', () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                  if (result != null && result.files.single.path != null) {
                    _showNameInputDialog(result.files.single.name, result.files.single.path!);
                  }
                }),
                _buildImportButton(Icons.videocam, 'import\nvideo', () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
                  if (result != null && result.files.single.path != null) {
                    _showNameInputDialog(result.files.single.name, result.files.single.path!);
                  }
                }),
                _buildImportButton(Icons.create_new_folder, 'New\nFolder', () {
                  _showNameInputDialog('New Folder', null, isFolder: true);
                }),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
  child: ListView(
    children: [
      if (_currentFolder.isNotEmpty)
        ..._items
        .where((item) => item['folder'] == 'See All' && item['isFolder'] == 'true')
        .map((item) {
          return ListTile(
            leading: const Icon(Icons.folder),
            title: Text(item['name'] ?? ''),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  setState(() {
                    _items.remove(item);
                  });
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
           onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => FolderScreen(
        folderName: item['name']!,
        items: _items,
        onAddItem: (newItem) {
          setState(() {
            _items.add(newItem);
          });
        },
      ),
    ),
  );
},

          );
        }),

    ...filteredItems.isEmpty
    ? [const Center(child: Text('No results found'))]
    : filteredItems
          .where((item) {
    final name = item['name']?.toLowerCase() ?? '';
    final folder = item['folder'] ?? '';
    final matchesQuery = _searchQuery.isEmpty || name.contains(_searchQuery.toLowerCase());

    final matchesFolder = _currentFolder.isEmpty
        ? (folder == _currentFolder || folder == 'See All')
        : folder == _currentFolder;

    return matchesQuery && matchesFolder;
  })
  .map((item) {
    if (item['isFolder'] == 'true') {
      return ListTile(
        leading: const Icon(Icons.folder),
        title: Text(item['name'] ?? ''),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              setState(() {
                _items.remove(item);
              });
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
        onTap: () {
          setState(() {
            _currentFolder = item['name']!;
          });
        },
      );
    } else {
      return ListTile(
        leading: Icon(_getFileIcon(item['path'] ?? '')),
        title: Text(item['name'] ?? ''),
        subtitle: Text(item['folder'] ?? 'No Folder'),
        onTap: () {
          _previewFile(item['path'] ?? '');
        },
      );
    }
  }),
    ],
  ),
),

          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          color: Color(0xFF7D4A3B),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: GNav(
            rippleColor: Colors.grey[800]!,
            hoverColor: Colors.grey[700]!,
            haptic: true,
            tabBorderRadius: 20,
            gap: 8,
            backgroundColor: const Color(0xFF7D4A3B),
            color: Colors.black54,
            activeColor: Colors.black,
            iconSize: 24,
            tabBackgroundColor: const Color.fromRGBO(255, 255, 255, 0.9),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            selectedIndex: _selectedIndex,
            onTabChange: onItemTapped,
            tabs: const [
              GButton(icon: LineIcons.home, text: ''),
              GButton(icon: LineIcons.calendar, text: ''),
              GButton(icon: LineIcons.comment, text: ''),
              GButton(icon: LineIcons.bell, text: ''),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 30, color: Colors.black),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
    );
  }

  void _showNameInputDialog(String defaultName, String? filePath, {bool isFolder = false}) {
    String name = defaultName;
    String folder = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isFolder ? 'New Folder' : 'Add File'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: isFolder ? 'Folder Name' : 'File Name'),
                onChanged: (value) => name = value,
              ),
              if (!isFolder)
                TextField(
                  decoration: const InputDecoration(labelText: 'Folder (Optional)'),
                  onChanged: (value) => folder = value,
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addFileToList(
                  name,
                  isFolder ? '' : folder,
                  filePath ?? '',
                  isFolder: isFolder,
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addFileToList(String fileName, String folder, String filePath, {bool isFolder = false}) {
    setState(() {
      _items.add({
        'name': fileName,
        'folder': folder.isEmpty ? 'See All' : folder,
        'path': filePath,
        'isFolder': isFolder.toString(),
      });
    });
  }

  IconData _getFileIcon(String path) {
    if (path.endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png')) {
      return Icons.image;
    } else if (path.endsWith('.mp4')) {
      return Icons.videocam;
    }
    return Icons.file_present;
  }

  void _previewFile(String filePath) async {
    if (filePath.isNotEmpty) {
      await OpenFilex.open(filePath); // 🔥 Opens the file
    }
  }
}

class FolderScreen extends StatefulWidget {
  final String folderName;
  final List<Map<String, String>> items;
  final Function(Map<String, String>) onAddItem;

  const FolderScreen({
    super.key,
    required this.folderName,
    required this.items,
    required this.onAddItem,
  });

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  late String _currentFolder;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _currentFolder = widget.folderName;
  }

  List<Map<String, String>> get filteredItems {
    return widget.items.where((item) {
      final name = item['name']?.toLowerCase() ?? '';
      final folder = item['folder'] ?? '';
      final matchesQuery = _searchQuery.isEmpty || name.contains(_searchQuery.toLowerCase());
      final matchesFolder = folder == _currentFolder;
      return matchesQuery && matchesFolder;
    }).toList();
  }

  void _showNameInputDialog(String defaultName, String? filePath, {bool isFolder = false}) {
    String name = defaultName;
    

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isFolder ? 'New Folder' : 'Add File'),
          content: TextField(
            decoration: InputDecoration(labelText: isFolder ? 'Folder Name' : 'File Name'),
            onChanged: (value) => name = value,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onAddItem({
                  'name': name,
                  'folder': _currentFolder,
                  'path': filePath ?? '',
                  'isFolder': isFolder.toString(),
                });
                setState(() {}); // Refresh list
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    
  }

  IconData _getFileIcon(String path) {
    if (path.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png')) return Icons.image;
    if (path.endsWith('.mp4')) return Icons.videocam;
    return Icons.insert_drive_file;
  }

  void _previewFile(String filePath) async {
    if (filePath.isNotEmpty) {
      await OpenFilex.open(filePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5E6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buttons (file, image, video, folder)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildImportButton(Icons.insert_drive_file, 'import\nFile', () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
                  );
                  if (result != null && result.files.single.path != null) {
                    _showNameInputDialog(result.files.single.name, result.files.single.path!);
                  }
                }),
                _buildImportButton(Icons.image, 'import\nimage', () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                  if (result != null && result.files.single.path != null) {
                    _showNameInputDialog(result.files.single.name, result.files.single.path!);
                  }
                }),
                _buildImportButton(Icons.videocam, 'import\nvideo', () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
                  if (result != null && result.files.single.path != null) {
                    _showNameInputDialog(result.files.single.name, result.files.single.path!);
                  }
                }),
                _buildImportButton(Icons.create_new_folder, 'New\nFolder', () {
                  _showNameInputDialog('New Folder', null, isFolder: true);
                }),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredItems.isEmpty
                  ? const Center(child: Text('No results found'))
                  : ListView(
                      children: filteredItems.map((item) {
                        if (item['isFolder'] == 'true') {
                          return ListTile(
                            leading: const Icon(Icons.folder),
                            title: Text(item['name'] ?? ''),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'delete') {
                                  setState(() {
                                    widget.items.remove(item);
                                  });
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FolderScreen(
                                    folderName: item['name']!,
                                    items: widget.items,
                                    onAddItem: widget.onAddItem,
                                  ),
                                ),
                              );
                            },
                          );
                          
                        } else {
                         return ListTile(
  leading: Icon(_getFileIcon(item['path'] ?? '')),
  title: Text(item['name'] ?? ''),
  trailing: PopupMenuButton<String>(
    onSelected: (value) {
      if (value == 'delete') {
        setState(() {
          widget.items.remove(item);
        });
      }
    },
    itemBuilder: (context) => const [
      PopupMenuItem(value: 'delete', child: Text('Delete')),
    ],
  ),
  onTap: () => _previewFile(item['path'] ?? ''),
);

                        }
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 30, color: Colors.black),
          ),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black)),
        ],
      ),
    );
  }
}

