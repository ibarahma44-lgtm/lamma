import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  List<Map<String, String>> books = [];
  bool _isLoading = true;

  // Predefined categories
  static const Map<String, List<Map<String, String>>> _preloadedBooks = {
    'Novel': [
      {
        'title': 'في قلبي أنثى عبرية',
        'author': 'خولة حمدي',
        'url': 'https://www.noor-book.com/en/pdf/في-قلبي-أنثى-عبرية-pdf',
        'emoji': '📖',
        'category': 'Novel',
      },
      {
        'title': 'أبابيل',
        'author': 'أحمد آل حمدان',
        'url': 'https://foulabook.com/ar/book/رواية-أبابيل-pdf',
        'emoji': '📚',
        'category': 'Novel',
      },
      {
        'title': 'The Great Gatsby',
        'author': 'F. Scott Fitzgerald',
        'url': 'https://www.planetebook.com/free-ebooks/the-great-gatsby.pdf',
        'emoji': '📖',
        'category': 'Novel',
      },
      {
        'title': 'Pride and Prejudice',
        'author': 'Jane Austen',
        'url': 'https://www.planetebook.com/free-ebooks/pride-and-prejudice.pdf',
        'emoji': '📚',
        'category': 'Novel',
      },
      {
        'title': '1984',
        'author': 'George Orwell',
        'url': 'https://www.planetebook.com/free-ebooks/1984.pdf',
        'emoji': '📖',
        'category': 'Novel',
      },
      {
        'title': 'To Kill a Mockingbird',
        'author': 'Harper Lee',
        'url': 'https://www.planetebook.com/free-ebooks/to-kill-a-mockingbird.pdf',
        'emoji': '📚',
        'category': 'Novel',
      },
      {
        'title': 'The Catcher in the Rye',
        'author': 'J.D. Salinger',
        'url': 'https://www.planetebook.com/free-ebooks/the-catcher-in-the-rye.pdf',
        'emoji': '📖',
        'category': 'Novel',
      },
      {
        'title': 'The Alchemist',
        'author': 'Paulo Coelho',
        'url': 'https://www.planetebook.com/free-ebooks/the-alchemist.pdf',
        'emoji': '📚',
        'category': 'Novel',
      },
    ],
    'Religion': [
      {
        'title': 'The Holy Quran',
        'author': 'Allah',
        'url': 'https://www.islamicbulletin.org/ebooks/quran/quran_english.pdf',
        'emoji': '📖',
        'category': 'Religion',
      },
      {
        'title': 'The Sealed Nectar',
        'author': 'Safiur-Rahman Al-Mubarakpuri',
        'url': 'https://www.islamicbulletin.org/ebooks/sealed_nectar.pdf',
        'emoji': '📚',
        'category': 'Religion',
      },
      {
        'title': 'The Divine Reality',
        'author': 'Hamza Andreas Tzortzis',
        'url': 'https://www.islamicbulletin.org/ebooks/divine_reality.pdf',
        'emoji': '📖',
        'category': 'Religion',
      },
      {
        'title': 'The Purpose of Life',
        'author': 'Jeffrey Lang',
        'url': 'https://www.islamicbulletin.org/ebooks/purpose_of_life.pdf',
        'emoji': '📚',
        'category': 'Religion',
      },
      {
        'title': 'The Road to Mecca',
        'author': 'Muhammad Asad',
        'url': 'https://www.islamicbulletin.org/ebooks/road_to_mecca.pdf',
        'emoji': '📖',
        'category': 'Religion',
      },
      {
        'title': 'The Vision of Islam',
        'author': 'Sachiko Murata',
        'url': 'https://www.islamicbulletin.org/ebooks/vision_of_islam.pdf',
        'emoji': '📚',
        'category': 'Religion',
      },
    ],
    'Self-Development': [
      {
        'title': 'Atomic Habits',
        'author': 'James Clear',
        'url': 'https://jamesclear.com/atomic-habits',
        'emoji': '📖',
        'category': 'Self-Development',
      },
      {
        'title': 'The 7 Habits of Highly Effective People',
        'author': 'Stephen Covey',
        'url': 'https://www.pdfdrive.com/the-7-habits-of-highly-effective-people-e183476.html',
        'emoji': '📚',
        'category': 'Self-Development',
      },
      {
        'title': 'Think and Grow Rich',
        'author': 'Napoleon Hill',
        'url': 'https://www.pdfdrive.com/think-and-grow-rich-e183476.html',
        'emoji': '📖',
        'category': 'Self-Development',
      },
      {
        'title': 'The Power of Now',
        'author': 'Eckhart Tolle',
        'url': 'https://www.pdfdrive.com/the-power-of-now-e183476.html',
        'emoji': '📚',
        'category': 'Self-Development',
      },
      {
        'title': 'Mindset: The New Psychology of Success',
        'author': 'Carol S. Dweck',
        'url': 'https://www.pdfdrive.com/mindset-the-new-psychology-of-success-e183476.html',
        'emoji': '📖',
        'category': 'Self-Development',
      },
    ],
    'Psychology': [
      {
        'title': 'Thinking, Fast and Slow',
        'author': 'Daniel Kahneman',
        'url': 'https://www.pdfdrive.com/thinking-fast-and-slow-e183476.html',
        'emoji': '📖',
        'category': 'Psychology',
      },
      {
        'title': 'The Psychology of Money',
        'author': 'Morgan Housel',
        'url': 'https://www.pdfdrive.com/the-psychology-of-money-e183476.html',
        'emoji': '📚',
        'category': 'Psychology',
      },
      {
        'title': 'Influence: The Psychology of Persuasion',
        'author': 'Robert B. Cialdini',
        'url': 'https://www.pdfdrive.com/influence-the-psychology-of-persuasion-e183476.html',
        'emoji': '📖',
        'category': 'Psychology',
      },
      {
        'title': 'The Art of Thinking Clearly',
        'author': 'Rolf Dobelli',
        'url': 'https://www.pdfdrive.com/the-art-of-thinking-clearly-e183476.html',
        'emoji': '📚',
        'category': 'Psychology',
      },
    ],
    'History': [
      {
        'title': 'Sapiens: A Brief History of Humankind',
        'author': 'Yuval Noah Harari',
        'url': 'https://www.pdfdrive.com/sapiens-a-brief-history-of-humankind-e183476.html',
        'emoji': '📖',
        'category': 'History',
      },
      {
        'title': 'Guns, Germs, and Steel',
        'author': 'Jared Diamond',
        'url': 'https://www.pdfdrive.com/guns-germs-and-steel-e183476.html',
        'emoji': '📚',
        'category': 'History',
      },
      {
        'title': 'The Silk Roads',
        'author': 'Peter Frankopan',
        'url': 'https://www.pdfdrive.com/the-silk-roads-e183476.html',
        'emoji': '📖',
        'category': 'History',
      },
    ],
    'Science': [
      {
        'title': 'A Brief History of Time',
        'author': 'Stephen Hawking',
        'url': 'https://www.pdfdrive.com/a-brief-history-of-time-e183476.html',
        'emoji': '📖',
        'category': 'Science',
      },
      {
        'title': 'The Selfish Gene',
        'author': 'Richard Dawkins',
        'url': 'https://www.pdfdrive.com/the-selfish-gene-e183476.html',
        'emoji': '📚',
        'category': 'Science',
      },
    ],
    'Literary': [
      {
        'title': 'The Art of War',
        'author': 'Sun Tzu',
        'url': 'https://www.pdfdrive.com/the-art-of-war-e183476.html',
        'emoji': '📖',
        'category': 'Literary',
      },
      {
        'title': 'Meditations',
        'author': 'Marcus Aurelius',
        'url': 'https://www.pdfdrive.com/meditations-e183476.html',
        'emoji': '📚',
        'category': 'Literary',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final booksJson = prefs.getStringList('library_books') ?? [];
    
    if (booksJson.isEmpty) {
      // Preload all categorized books if library is empty
      books = _preloadedBooks.values.expand((books) => books).toList();
      await _saveBooks();
    } else {
      books = booksJson.map((json) => Map<String, String>.from(jsonDecode(json))).toList();
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _saveBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final booksJson = books.map((book) => jsonEncode(book)).toList();
    await prefs.setStringList('library_books', booksJson);
  }

  void _addBook() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        books.insert(0, {
          'title': _titleController.text.trim(),
          'author': _authorController.text.trim(),
          'url': _urlController.text.trim(),
          'emoji': '📘',
          'category': 'Custom', // Default category for manually added books
        });
        _titleController.clear();
        _authorController.clear();
        _urlController.clear();
      });
      _saveBooks();
    }
  }

  Future<void> _deleteBook(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Book'),
        content: Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        books.removeAt(index);
      });
      await _saveBooks();
    }
  }

  void _readBook(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the book.')),
      );
    }
  }

  void _downloadBook(String url) async {
    // For now, just open the URL. You can implement file download if needed.
    _readBook(url);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF0D4D4D);
    return Scaffold(
      appBar: AppBar(
        title: Text('Library', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 2,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Add a New Book', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor)),
                            SizedBox(height: 12),
                            TextFormField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                labelText: 'Title',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a title' : null,
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              controller: _authorController,
                              decoration: InputDecoration(
                                labelText: 'Author',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter an author' : null,
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              controller: _urlController,
                              decoration: InputDecoration(
                                labelText: 'PDF URL',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a PDF URL' : null,
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _addBook,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text('Save', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text('Books', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 20, color: primaryColor)),
                  SizedBox(height: 8),
                  Expanded(
                    child: books.isEmpty
                        ? Center(child: Text('No books yet.', style: TextStyle(color: Colors.grey)))
                        : ListView.separated(
                            itemCount: books.length,
                            separatorBuilder: (_, __) => SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final book = books[index];
                              return Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(book['emoji'] ?? '📘', style: TextStyle(fontSize: 32)),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(book['title'] ?? '', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor)),
                                            SizedBox(height: 4),
                                            Text('by ${book['author'] ?? ''}', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.black87)),
                                            if (book['category'] != null) ...[
                                              SizedBox(height: 4),
                                              Text(
                                                book['category']!,
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 12,
                                                  color: primaryColor.withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () => _readBook(book['url'] ?? ''),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                            ),
                                            child: Text('Read', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                                          ),
                                          SizedBox(height: 8),
                                          OutlinedButton(
                                            onPressed: () => _downloadBook(book['url'] ?? ''),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: primaryColor,
                                              side: BorderSide(color: primaryColor),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            ),
                                            child: Text('Download', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                                          ),
                                          SizedBox(height: 8),
                                          IconButton(
                                            icon: Icon(Icons.delete_outline, color: Colors.red),
                                            onPressed: () => _deleteBook(index),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
} 