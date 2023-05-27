// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_declarations, avoid_print, use_build_context_synchronously, unused_import, unused_local_variable
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../bloc/settings/settings_cubit.dart';
import '../localizations/localizations.dart';

class TicketScreen extends StatefulWidget {
  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  List<dynamic> supports = [];
  List<int> selectedSupportIds = [];
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    fetchSupport();
  }

  Future<void> fetchSupport() async {
    final url = 'https://api.qline.app/api/tickets/';
    final settings = context.read<SettingsCubit>();
    final bearerToken = settings.state.userData[3];
    final headers = {'Authorization': 'Bearer $bearerToken'};
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      final responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(
          () {
            supports = responseBody
                .map((ticket) => {...ticket, 'isSelected': false})
                .toList();
          },
        );
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void toggleEditing() {
    setState(() {
      isEditing = !isEditing;
    });

    if (!isEditing) {
      selectedSupportIds.clear();
      for (final ticket in supports) {
        ticket['isSelected'] = false;
      }
    }
  }

  void selectSupport(int? ticketId) {
    setState(() {
      for (final ticket in supports) {
        ticket['isSelected'] = (ticket['id'] == ticketId);
      }
    });
    selectedSupportIds.clear();
    if (isEditing && ticketId != null) {
      selectedSupportIds.add(ticketId);
    } else {
      selectedSupportIds.clear();
    }
  }

  void resetTileColor(int ticketId) {
    final index = supports.indexWhere((ticket) => ticket['id'] == ticketId);
    if (index != -1) {
      setState(() {
        supports[index]['isSelected'] = false;
      });
    }
  }

  Future<void> removeSelectedSupport() async {
    final url = 'https://api.qline.app/api/tickets/close';
    final settings = context.read<SettingsCubit>();
    final bearerToken = settings.state.userData[3];
    final headers = {'Authorization': 'Bearer $bearerToken'};
    try {
      for (final ticketId in selectedSupportIds) {
        final body = {'id': ticketId.toString()};
        final response =
            await http.post(Uri.parse(url), headers: headers, body: body);
        if (response.statusCode == 200) {
          setState(() {
            supports.removeWhere((ticket) => ticket['id'] == ticketId);
          });
        } else {
          print('Error deleting ticket $ticketId: ${response.statusCode}');
        }
      }
      selectedSupportIds.clear();
      fetchSupport();
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).getTranslate('support_screen'),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).go('/profile'); // Anasayfaya yönlendirme
          },
        ),
        actions: [
          if (isEditing)
            TextButton(
              onPressed: removeSelectedSupport,
              child: Text(
                AppLocalizations.of(context).getTranslate('remove'),
              ),
            ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: toggleEditing,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: supports.length,
        itemBuilder: (BuildContext context, int index) {
          final ticket = supports[index];
          final ticketId = ticket['id'];
          final isSelected = ticket['isSelected'] ?? false;
          Widget tile;
          if (isEditing) {
            tile = RadioListTile<int>(
              value: ticketId,
              groupValue: selectedSupportIds.isNotEmpty
                  ? selectedSupportIds.first
                  : null,
              title: Text(ticket['title']),
              subtitle: Text('Status: ${ticket['status']}'),
              onChanged: selectSupport,
            );
          } else {
            tile = ListTile(
              title: Text(ticket['title']),
              subtitle: Text('Status: ${ticket['status']}'),
              onTap: () {
                ///
              },
            );
          }
          return Card(
            child: tile,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isEditing) {
            final selectedTicketId =
                selectedSupportIds.isNotEmpty ? selectedSupportIds.first : null;
            if (selectedTicketId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ReplySupportScreen(ticketId: selectedTicketId),
                ),
              ).then(
                (value) {
                  if (value == 'done') {
                    toggleEditing();
                  }
                },
              );
            } else {
              //
            }
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTicketScreen()),
            ).then(
              (value) {
                //
              },
            );
          }
        },
        child: isEditing ? Icon(Icons.reply_outlined) : Icon(Icons.add),
      ),
    );
  }
}

class AddTicketScreen extends StatefulWidget {
  @override
  _AddTicketScreenState createState() => _AddTicketScreenState();
}

class _AddTicketScreenState extends State<AddTicketScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  TextEditingController topicController = TextEditingController();

  void createTicket() async {
    final createUrl = 'https://api.qline.app/api/tickets/';
    final settings = context.read<SettingsCubit>();
    final bearerToken = settings.state.userData[3];
    final headers = {'Authorization': 'Bearer $bearerToken'};
    final body = {
      'title': titleController.text,
      'message': messageController.text,
      'topic': topicController.text,
    };

    try {
      final response =
          await http.post(Uri.parse(createUrl), headers: headers, body: body);

      if (response.statusCode == 301) {
        final redirectUrl = response.headers['location'];

        if (redirectUrl != null) {
          final redirectedResponse = await http.post(Uri.parse(redirectUrl),
              headers: headers, body: body);

          if (redirectedResponse.statusCode == 200) {
            Navigator.pop(context);
          } else {
            print('Error: ${redirectedResponse.statusCode}');
          }
        } else {
          print('Error: Redirect URL not found');
        }
      } else if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).getTranslate('add_ticket'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).getTranslate('title'),
              ),
            ),
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).getTranslate('massage'),
              ),
            ),
            TextField(
              controller: topicController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).getTranslate('topic'),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: createTicket,
              child: Text(
                AppLocalizations.of(context).getTranslate('create_ticket'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReplySupportScreen extends StatefulWidget {
  final int ticketId;

  const ReplySupportScreen({Key? key, required this.ticketId})
      : super(key: key);

  @override
  _ReplySupportScreenState createState() => _ReplySupportScreenState();
}

class _ReplySupportScreenState extends State<ReplySupportScreen> {
  TextEditingController replyController = TextEditingController();

  void replyToSupport() async {
    final replyUrl = 'https://api.qline.app/api/tickets/respond';
    final settings = context.read<SettingsCubit>();
    final bearerToken = settings.state.userData[3];
    final headers = {'Authorization': 'Bearer $bearerToken'};
    final body = {
      'id': widget.ticketId.toString(),
      'message': replyController.text,
    };

    try {
      final response =
          await http.post(Uri.parse(replyUrl), headers: headers, body: body);

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).getTranslate('reply_support'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: replyController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).getTranslate('reply1'),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: replyToSupport,
              child: Text(
                AppLocalizations.of(context).getTranslate('reply2'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
