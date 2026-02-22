import 'dart:math';

import 'package:debate_bot/pages/chat.dart';
import 'package:flutter/material.dart';
import 'summary.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

enum Side { aff, neg }

const _difficultyOptions = ['easy', 'intermediate', 'advanced', 'impossible'];

class _HomeState extends State<Home> {
  final inputcontroller = TextEditingController();
  Side sideView = Side.aff;
  String _difficulty = _difficultyOptions[2]; // default: 'advanced'

  List<Widget>? _topics;

  @override
  void initState() {
    super.initState();

    _topics = [
      _randomTopicChip(),
      _topicChip("Should school uniforms be mandatory?"),
      _topicChip("Should social media be banned?"),
      _topicChip("Should college education be free?"),
      _topicChip("Is space exploration worth the cost?"),
      _topicChip("Should homework be abolished?"),
      _topicChip("Should phones be banned for students?"),
      _topicChip("Should voting be mandatory?"),
      _topicChip("Should the Electoral College be abolished in the U.S.?"),
      _topicChip("Is democracy the best form of government?"),
      _topicChip("Should the voting age be lowered to 16?"),
      _topicChip("Should political campaigns have spending limits?"),
      _topicChip("Is nationalism harmful or beneficial?"),
      _topicChip("Should there be term limits for all politicians?"),
      _topicChip("Is universal basic income a good solution to poverty?"),
      _topicChip("Should governments regulate social media platforms?"),
      _topicChip("Is censorship ever justified?"),
      _topicChip("Is artificial intelligence a threat to humanity?"),
      _topicChip("Should AI replace human workers in dangerous jobs?"),
      _topicChip("Should social media require age verification?"),
      _topicChip("Is technology making people less social?"),
      _topicChip("Should governments regulate cryptocurrency?"),
      _topicChip("Is data privacy more important than national security?"),
      _topicChip("Should facial recognition technology be banned?"),
      _topicChip("Is space exploration worth the cost?"),
      _topicChip("Should self-driving cars be allowed on all roads?"),
      _topicChip("Is remote work better than office work?"),
      _topicChip("Should college be free?"),
      _topicChip("Is homework beneficial?"),
      _topicChip("Should standardized testing be eliminated?"),
      _topicChip("Should schools teach financial literacy?"),
      _topicChip("Is online learning as effective as in-person learning?"),
      _topicChip("Should schools require uniforms?"),
      _topicChip("Should students evaluate their teachers?"),
      _topicChip("Is year-round schooling better?"),
      _topicChip("Should coding be mandatory in schools?"),
      _topicChip("Should grades be abolished?"),
      _topicChip("Is lying ever morally acceptable?"),
      _topicChip("Should the death penalty be abolished?"),
      _topicChip("Is free will real?"),
      _topicChip("Should animal testing be banned?"),
      _topicChip("Is wealth inequality inevitable?"),
      _topicChip("Should assisted suicide be legal?"),
      _topicChip("Is cancel culture justified?"),
      _topicChip("Should billionaires exist?"),
      _topicChip("Is morality subjective or objective?"),
      _topicChip("Do the ends justify the means?"),
      _topicChip("Should plastic be completely banned?"),
      _topicChip("Is climate change the greatest threat to humanity?"),
      _topicChip("Should meat consumption be reduced globally?"),
      _topicChip("Is nuclear energy a good alternative to fossil fuels?"),
      _topicChip("Should governments subsidize electric vehicles?"),
      _topicChip("Is overpopulation a serious global issue?"),
      _topicChip("Should companies be fined heavily for pollution?"),
      _topicChip("Is individual action enough to fight climate change?"),
      _topicChip("Should water be privatized?"),
      _topicChip("Should fast fashion be regulated?"),
      _topicChip("Is social media doing more harm than good?"),
      _topicChip("Should influencers be regulated?"),
      _topicChip("Is cancel culture harmful?"),
      _topicChip("Should freedom of speech have limits?"),
      _topicChip("Are beauty standards damaging society?"),
      _topicChip("Should violent video games be restricted?"),
      _topicChip("Is traditional marriage outdated?"),
      _topicChip("Should cultural appropriation be criticized?"),
      _topicChip("Are reality TV shows harmful?"),
      _topicChip("Should celebrities be political role models?"),
      _topicChip("Should the minimum wage be raised?"),
      _topicChip("Is capitalism the best economic system?"),
      _topicChip("Should corporations be taxed more?"),
      _topicChip("Is remote work hurting the economy?"),
      _topicChip("Should internships always be paid?"),
      _topicChip("Is entrepreneurship overrated?"),
      _topicChip("Should monopolies be broken up?"),
      _topicChip("Is the gig economy exploitative?"),
      _topicChip("Should student loan debt be forgiven?"),
      _topicChip("Is consumerism harmful?"),
      _topicChip("Should vaccines be mandatory?"),
      _topicChip("Is genetic engineering ethical?"),
      _topicChip("Should junk food advertising be banned?"),
      _topicChip("Is mental health prioritized enough?"),
      _topicChip("Should healthcare be universal?"),
      _topicChip("Is alternative medicine effective?"),
      _topicChip("Should organ donation be opt-out?"),
      _topicChip("Is human cloning ever acceptable?"),
      _topicChip("Should athletes be allowed to use performance enhancers?"),
      _topicChip(
        "Is obesity a public health issue or personal responsibility?",
      ),
      _topicChip("Should college athletes be paid?"),
      _topicChip("Is esports a real sport?"),
      _topicChip("Should performance-enhancing drugs be legalized in sports?"),
      _topicChip("Are sports salaries too high?"),
      _topicChip("Should violent sports be banned?"),
      _topicChip("Is VAR (video assistant referee) good for sports?"),
      _topicChip("Should the Olympics remove certain events?"),
      _topicChip("Are award shows still relevant?"),
      _topicChip("Should movies reflect social issues?"),
      _topicChip("Is streaming better than traditional cinema?"),
      _topicChip("Should humans colonize Mars?"),
      _topicChip("Is immortality desirable?"),
      _topicChip("Should robots have rights?"),
      _topicChip("Will AI replace most jobs?"),
      _topicChip("Is privacy dead in the digital age?"),
      _topicChip("Should governments control population growth?"),
      _topicChip("Is humanity inherently good or evil?"),
      _topicChip("Will technology solve climate change?"),
      _topicChip("Should there be limits on scientific research?"),
      _topicChip("Is progress always good?"),
    ];
  }

  void _navigateToSummary() {
    if (inputcontroller.text.trim().isEmpty) return;

    MeterDataHolder().setUserRating(50);
    final difficultyStr =
        _difficulty[0].toUpperCase() + _difficulty.substring(1);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Summary(
          input: sideView == Side.aff
              ? "Affirmative on '${inputcontroller.text}' with difficulty: $difficultyStr"
              : "Negative on '${inputcontroller.text}' with difficulty: $difficultyStr",
          rawInput: inputcontroller.text,
          difficulty: difficultyStr,
        ),
      ),
    );
  }

  Widget _buildSegmentedButton(bool isNarrow) {
    return SegmentedButton<Side>(
      showSelectedIcon: false,
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      segments: <ButtonSegment<Side>>[
        ButtonSegment<Side>(
          value: Side.aff,
          label: Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text('AFF'),
          ),
        ),
        ButtonSegment<Side>(value: Side.neg, label: Text('NEG')),
      ],
      selected: <Side>{sideView},
      onSelectionChanged: (Set<Side> newSelection) {
        setState(() {
          sideView = newSelection.first;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Debate Bot - Home"),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 1200;
          return Center(
            child: Column(
              children: [
                SizedBox(height: constraints.maxHeight > 700 ? 160 : 8),
                Image.asset(
                  'assets/images/robot-bot-black-icon.png',
                  height: isNarrow
                      ? (constraints.maxHeight < 700 ? 100 : 200)
                      : 350,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 8),
                Text(
                  "Welcome to Debate Bot",
                  style: TextStyle(
                    fontSize: isNarrow ? 18 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Win Your Debates",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),

                Spacer(),
                ScrollConfiguration(
                  behavior: ScrollConfiguration.of(
                    context,
                  ).copyWith(overscroll: false),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: _topics ?? [LinearProgressIndicator()],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                !isNarrow ? SizedBox(height: 8) : SizedBox(height: 0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: isNarrow
                      ? Column(
                          children: [
                            Row(
                              children: [
                                _buildSegmentedButton(isNarrow),
                                SizedBox(width: 8),
                                Expanded(child: _difficultySelector()),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: inputcontroller,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: "Type your topic here.",
                                    ),
                                    onSubmitted: (_) => _navigateToSummary(),
                                  ),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.send),
                                  onPressed: _navigateToSummary,
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            _buildSegmentedButton(isNarrow),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: inputcontroller,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText:
                                      "Type your topic here to get started.",
                                ),
                                onSubmitted: (_) => _navigateToSummary(),
                              ),
                            ),
                            SizedBox(width: 8),
                            SizedBox(width: 160, child: _difficultySelector()),
                            SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.send),
                              onPressed: _navigateToSummary,
                            ),
                            SizedBox(width: 8),
                          ],
                        ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: Text(
                    "Make sure to Check Debate Bot's Work!",
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _difficultySelector() {
    return InputDecorator(
      decoration: InputDecoration(border: OutlineInputBorder()),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _difficulty,
          isExpanded: true,
          isDense: true,
          items: _difficultyOptions
              .map(
                (d) => DropdownMenuItem(
                  value: d,
                  child: Text(d[0].toUpperCase() + d.substring(1)),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _difficulty = v!),
        ),
      ),
    );
  }

  Widget _topicChip(String topic) {
    return Row(
      children: [
        ActionChip(
          label: Text(topic),
          onPressed: () {
            setState(() {
              inputcontroller.text = topic;
              sideView = Side.aff;
            });
          },
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _randomTopicChip() {
    return Row(
      children: [
        ActionChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(Icons.casino_outlined, size: 20)],
          ),
          onPressed: () {
            try {
              ActionChip target =
                  (_topics![max(1, Random().nextInt(_topics!.length))] as Row)
                          .children[0]
                      as ActionChip;
              target.onPressed!.call();
            } catch (error) {
              return;
            }
          },
        ),
        SizedBox(width: 8),
      ],
    );
  }
}
