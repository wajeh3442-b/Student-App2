import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QuizHomePage(),
    );
  }
}

class Question {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });

  Question shuffled() {
    final shuffledOptions = List<String>.from(options);
    shuffledOptions.shuffle();
    final newCorrectIndex = shuffledOptions.indexOf(options[correctAnswerIndex]);
    return Question(
      question: question,
      options: shuffledOptions,
      correctAnswerIndex: newCorrectIndex,
    );
  }
}

class QuizHomePage extends StatefulWidget {
  const QuizHomePage({super.key});

  @override
  State<QuizHomePage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _highScore = 0;
  bool _showFeedback = false;
  bool _isCorrect = false;
  int? _selectedAnswer;
  Timer? _timer;
  int _timeLeft = 10; // seconds per question
  bool _timerEnabled = true; // optional timer

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _initializeQuestions();
  }

  void _initializeQuestions() {
    _questions = [
      Question(
        question: 'What is the capital of France?',
        options: ['Paris', 'London', 'Berlin', 'Madrid'],
        correctAnswerIndex: 0,
      ),
      Question(
        question: 'Which planet is known as the Red Planet?',
        options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
        correctAnswerIndex: 1,
      ),
      Question(
        question: 'What is 2 + 2?',
        options: ['3', '4', '5', '6'],
        correctAnswerIndex: 1,
      ),
      Question(
        question: 'Who wrote "To Kill a Mockingbird"?',
        options: ['Harper Lee', 'J.K. Rowling', 'Stephen King', 'Mark Twain'],
        correctAnswerIndex: 0,
      ),
      Question(
        question: 'What is the largest ocean on Earth?',
        options: ['Atlantic', 'Indian', 'Arctic', 'Pacific'],
        correctAnswerIndex: 3,
      ),
    ];
    _questions.shuffle(); // shuffle questions
    _questions = _questions.map((q) => q.shuffled()).toList(); // shuffle options
    _startTimer();
  }

  void _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  void _saveHighScore(int score) async {
    if (score > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', score);
      setState(() {
        _highScore = score;
      });
    }
  }

  void _startTimer() {
    if (_timerEnabled) {
      _timeLeft = 10;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _timeLeft--;
        });
        if (_timeLeft == 0) {
          _nextQuestion();
        }
      });
    }
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _selectAnswer(int index) {
    if (_showFeedback) return;
    setState(() {
      _selectedAnswer = index;
      _isCorrect = index == _questions[_currentQuestionIndex].correctAnswerIndex;
      if (_isCorrect) _score++;
      _showFeedback = true;
    });
    _stopTimer();
  }

  void _nextQuestion() {
    _stopTimer();
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _showFeedback = false;
        _selectedAnswer = null;
      });
      _startTimer();
    } else {
      _saveHighScore(_score);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            score: _score,
            total: _questions.length,
            highScore: _highScore,
            onRestart: _restartQuiz,
          ),
        ),
      );
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _showFeedback = false;
      _selectedAnswer = null;
    });
    _initializeQuestions();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Score: $_score'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_timerEnabled)
              LinearProgressIndicator(
                value: _timeLeft / 10,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _timeLeft > 3 ? Colors.blue : Colors.red,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              'Question ${_currentQuestionIndex + 1}/${_questions.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            AnimatedOpacity(
              opacity: _showFeedback ? 0.5 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Text(
                question.question,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 20),
            ...question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              Color? color;
              if (_showFeedback) {
                if (index == question.correctAnswerIndex) {
                  color = Colors.green;
                } else if (index == _selectedAnswer) {
                  color = Colors.red;
                }
              }
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color ?? Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _showFeedback ? null : () => _selectAnswer(index),
                  child: Text(option),
                ),
              );
            }),
            const SizedBox(height: 20),
            if (_showFeedback)
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _isCorrect ? 'Correct!' : 'Incorrect!',
                  style: TextStyle(
                    fontSize: 20,
                    color: _isCorrect ? Colors.green : Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const Spacer(),
            if (_showFeedback)
              ElevatedButton(
                onPressed: _nextQuestion,
                child: Text(_currentQuestionIndex < _questions.length - 1 ? 'Next' : 'Finish'),
              ),
          ],
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final int score;
  final int total;
  final int highScore;
  final VoidCallback onRestart;

  const ResultPage({
    super.key,
    required this.score,
    required this.total,
    required this.highScore,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score / total * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Score: $score / $total',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '$percentage%',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              'High Score: $highScore',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onRestart,
              child: const Text('Restart Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
