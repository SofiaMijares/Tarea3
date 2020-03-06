import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:tarea_dos/models/todo_remainder.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  // TODO: inicializar la box
  Box _listBox;


  @override
  HomeState get initialState => HomeInitialState();
  HomeBloc() {
    // referencia a la box
    _listBox = Hive.box("todosList");
  }

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if (event is OnLoadRemindersEvent) {
      try {
        List<TodoRemainder> _existingReminders = _loadReminders();
        yield LoadedRemindersState(todosList: _existingReminders);
      } on DatabaseDoesNotExist catch (_) {
        yield NoRemindersState();
      } on EmptyDatabase catch (_) {
        yield NoRemindersState();
      }
    }
    if (event is OnAddElementEvent) {
      _saveTodoReminder(event.todoReminder);
      yield NewReminderState(todo: event.todoReminder);
    }
    if (event is OnReminderAddedEvent) {
      yield AwaitingEventsState();
    }
    if (event is OnRemoveElementEvent) {
      _removeTodoReminder(event.removedAtIndex);
    }
  }

  List<TodoRemainder> _loadReminders() {
    // ver si existen datos TodoRemainder en la box y sacarlos como Lista (no es necesario hacer get ni put)
    
    //SI ESTA VACIA
    if(_listBox.values.first == null){
      throw EmptyDatabase();
    }
    
    //CARGA
    List<TodoRemainder>todosList = _listBox.values.map((todo) => todo as TodoRemainder).toList();
    //values: TodoRemainder
    return todosList;

    // debe haber un adapter para que la BD pueda detectar el objeto
  }

  void _saveTodoReminder(TodoRemainder todoReminder) {
    // TODO:add item here
    _listBox.add(todoReminder);
  }

  void _removeTodoReminder(int removedAtIndex) {
    // TODO:delete item here
    _listBox.deleteAt(removedAtIndex);
  }
}

class DatabaseDoesNotExist implements Exception {}

class EmptyDatabase implements Exception {}
