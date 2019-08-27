// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/yabr.1c/
// ----------------------------------------------------------

Перем ПараметрыОбработкиДанных;
Перем АктивныеОбработчики;
Перем РабочиеКаталоги;

#Область ПрограммныйИнтерфейс

// Процедура - устанавливает рабочий каталог
//
// Параметры:
//  Псевдоним    - Строка      -  псевдоним рабочего каталога для подстановки
//  Путь         - Строка      -  путь к рабочему каталогу
//
Процедура ДобавитьРабочийКаталог(Знач Псевдоним, Знач Путь) Экспорт
	
	Если НЕ ТипЗнч(РабочиеКаталоги) = Тип("Соответствие") Тогда
		РабочиеКаталоги = Новый Соответствие();
	КонецЕсли;
	
	РабочиеКаталоги.Вставить(Псевдоним, Путь);
	
КонецПроцедуры // ДобавитьРабочийКаталог()

// Функция - возвращает рабочий каталог по указанному псевдониму
//
// Параметры:
//  Псевдоним    - Строка      -  псевдоним рабочего каталога
//
// Возвращаемое значение:
//  Строка      - текущий рабочий каталог
//
Функция РабочийКаталог(Знач Псевдоним = "$workDir") Экспорт
	
	Возврат РабочиеКаталоги.Получить(Псевдоним);
	
КонецФункции // РабочийКаталог()

// Функция - возвращает параметры обработки данных
//
// Возвращаемое значение:
//  Структура                  - настройки обработки данных
//       *ПутьКОбработке       - Строка                 - путь к файлу внешней обработке
//       *ПроцедураОбработки   - Строка                 - имя процедуры обработки данных
//       *Параметры            - Строка                 - структура параметров процедуры обработки данных
//           *<Имя параметра>  - Произвольный           - знаечние параметра процедуры обработки данных
//       *АдресОбработки       - Строка                 - адрес внешней обработки во временном хранилище
//       *ИмяОбработки         - Строка                 - имя внешней обработки после подключения
//       *Обработчики          - Массив(Структура)      - массив обработчиков данных,
//                                                        полученных от обработки текущего уровня
//                                                        (состав полей элемента аналогичен текущему уровню) 
//
Функция ПараметрыОбработкиДанных() Экспорт
	
	Возврат ПараметрыОбработкиДанных;
	
КонецФункции // ПараметрыОбработкиДанных()

// Процедура - устанавливает параметры обработки данных
//
// Параметры:
//  НовыеПараметрыОбработкиДанных    - Структура, Строка      - новые параметры обработки данных
//                                     Файл, ДвоичныеДанные
//  Если тип параметра - Структура, то содержит следующие поля:
//       *ПутьКОбработке             - Строка                 - путь к файлу внешней обработке
//       *ПроцедураОбработки         - Строка                 - имя процедуры обработки данных
//       *Параметры                  - Строка                 - структура параметров процедуры обработки данных
//           *<Имя параметра>        - Произвольный           - знаечние параметра процедуры обработки данных
//       *АдресОбработки             - Строка                 - адрес внешней обработки во временном хранилище
//       *ИмяОбработки               - Строка                 - имя внешней обработки после подключения
//       *Обработчики                - Массив(Структура)      - массив обработчиков данных,
//                                                              полученных от обработки текущего уровня
//                                                              (состав полей элемента аналогичен текущему уровню) 
//
Процедура УстановитьПараметрыОбработкиДанных(Знач НовыеПараметрыОбработкиДанных) Экспорт
	
	ПроверитьДопустимостьТипа(НовыеПараметрыОбработкиДанных,
	                          "Строка, Файл, ДвоичныеДанные, Структура, Массив",
	                          СтрШаблон("Некорректно указаны параметры обработки данных ""%1"",",
	                                    СокрЛП(НовыеПараметрыОбработкиДанных)) +
							  ", тип ""%1"", ожидается тип %2!");
							  
	Если ТипЗнч(НовыеПараметрыОбработкиДанных) = Тип("Строка")
	   И ВРег(Лев(НовыеПараметрыОбработкиДанных, 18)) = ВРег("e1cib/tempstorage/") Тогда
		НовыеПараметрыОбработкиДанных = ПолучитьИзВременногоХранилища(НовыеПараметрыОбработкиДанных);
	КонецЕсли;

	Если ТипЗнч(НовыеПараметрыОбработкиДанных) = Тип("Структура")
	 ИЛИ ТипЗнч(НовыеПараметрыОбработкиДанных) = Тип("Массив") Тогда
		ПараметрыОбработкиДанных = НовыеПараметрыОбработкиДанных;
	Иначе
		ПараметрыОбработкиДанных = ПрочитатьПараметрыОбработкиДанных(НовыеПараметрыОбработкиДанных);
	КонецЕсли;
	
КонецПроцедуры // УстановитьПараметрыОбработкиДанных()

// Функция - читает и возвращает параметры обработки данных из файла JSON, указанного в поле "ПутьКФайлу"
//
// Параметры:
//  ПараметрыОбработки         - Строка, Файл,          - параметры обработки данных в формате JSON,
//                               ДвоичныеДанные           путь к файлу, файл или двоичные данные
//                                                        параметров обработки данных в формате JSON
// Возвращаемое значение:
//  Структура                  - настройки обработки данных
//       *ПутьКОбработке       - Строка                 - путь к файлу внешней обработке
//       *ПроцедураОбработки   - Строка                 - имя процедуры обработки данных
//       *Параметры            - Строка                 - структура параметров процедуры обработки данных
//           *<Имя параметра>  - Произвольный           - знаечние параметра процедуры обработки данных
//       *ИмяОбработки         - Строка                 - имя внешней обработки после подключения
//       *Обработчики          - Массив(Структура)      - массив обработчиков данных,
//                                                        полученных от обработки текущего уровня
//                                                        (состав полей элемента аналогичен текущему уровню) 
//
Функция ПрочитатьПараметрыОбработкиДанных(Знач ПараметрыОбработки) Экспорт
	
	ПроверитьДопустимостьТипа(ПараметрыОбработки,
	                          "Строка, Файл, ДвоичныеДанные",
	                          СтрШаблон("Некорректно указаны настройки ""%1"",", СокрЛП(ПараметрыОбработки)) +
							  ", тип ""%1"", ожидается тип %2!");
							  
	Если ТипЗнч(ПараметрыОбработки) = Тип("Строка")
	   И ВРег(Лев(ПараметрыОбработки, 18)) = ВРег("e1cib/tempstorage/") Тогда
		ПараметрыОбработки = ПолучитьИзВременногоХранилища(ПараметрыОбработки);
	КонецЕсли;

	ЧтениеПараметров = Новый ЧтениеJSON();
	
	Если ТипЗнч(ПараметрыОбработки) = Тип("Строка") Тогда
		Если Лев(СокрЛП(ПараметрыОбработки), 1) = "{" Тогда
			ЧтениеПараметров.УстановитьСтроку(ПараметрыОбработки);
		Иначе
			ЧтениеПараметров.ОткрытьФайл(ПараметрыОбработки);
		КонецЕсли;
	ИначеЕсли ТипЗнч(ПараметрыОбработки) = Тип("ДвоичныеДанные") Тогда
		ЧтениеПараметров.ОткрытьПоток(ПараметрыОбработки.ОткрытьПотокДляЧтения());
	ИначеЕсли ТипЗнч(ПараметрыОбработки) = Тип("Файл") Тогда
		ЧтениеПараметров.ОткрытьФайл(ПараметрыОбработки);
	Иначе
		ВызватьИсключение "Некорректно указаны настройки!";
	КонецЕсли;
	
	Возврат ПрочитатьJSON(ЧтениеПараметров, Ложь, , ФорматДатыJSON.ISO, "ОбработчикЧтенияПараметровИзJSON", ЭтотОбъект);
	
КонецФункции // ПрочитатьПараметрыОбработкиДанных()

// Процедура - выполняет обработку переданных данных с указанными параметрами
//
// Параметры:
//  Данные                           - Произвольный           - данные для обработки
//  ОписаниеОбработчика              - Структура              - описание обработчика данных
//       *ПутьКОбработке             - Строка                 - путь к файлу внешней обработке
//       *ПроцедураОбработки         - Строка                 - имя процедуры обработки данных
//       *Параметры                  - Строка                 - структура параметров процедуры обработки данных
//           *<Имя параметра>        - Произвольный           - знаечние параметра процедуры обработки данных
//       *АдресОбработки             - Строка                 - адрес внешней обработки во временном хранилище
//       *ИмяОбработки               - Строка                 - имя внешней обработки после подключения
//       *Обработчики                - Массив(Структура)      - массив обработчиков данных,
//                                                              полученных от обработки текущего уровня
//                                                              (состав полей элемента аналогичен текущему уровню) 
//
Процедура ОбработатьДанные(Знач Данные = Неопределено, Знач ОписаниеОбработчика = Неопределено) Экспорт
	
	Если НЕ (ТипЗнч(ОписаниеОбработчика) = Тип("Структура") 
	 ИЛИ ТипЗнч(ОписаниеОбработчика) = Тип("Массив")) Тогда
		ОписаниеОбработчика = ПараметрыОбработкиДанных;
	КонецЕсли;
	
	Если ТипЗнч(ОписаниеОбработчика) = Тип("Массив") Тогда
		Для Каждого ТекОписаниеОбработчика Из ОписаниеОбработчика Цикл
			ОбработатьДанные(Данные, ТекОписаниеобработчика);
		КонецЦикла;
		Возврат;
	КонецЕсли;
	
	ИнициализироватьОбработчикДанных(ОписаниеОбработчика);

	Если НЕ Данные = Неопределено Тогда
		ОписаниеОбработчика.Обработка.УстановитьДанные(Данные);
	КонецЕсли;
		
	Если ОписаниеОбработчика.Свойство("ПроцедураОбработки") Тогда
		Выполнить("ПараметрыОбработки.Обработка." + ОписаниеОбработчика.ПроцедураОбработки + "()");
	Иначе
		ОписаниеОбработчика.Обработка.ОбработатьДанные();
	КонецЕсли;
	
КонецПроцедуры // ОбработатьДанные()

// Процедура - обратного вызова (callback) выполняет вызов обработчиков для переданных данных
//
// Параметры:
//  Данные           - Строка     - данные для обработки
//  ИдОбработчика    - Строка     - идентификатор обработчика
//
Процедура ПродолжениеОбработкиДанных(Знач Данные, Знач ИдОбработчика) Экспорт
	
	ОписаниеОбработчика = АктивныеОбработчики.Получить(ИдОбработчика);
	
	Если НЕ ОписаниеОбработчика.Свойство("Обработчики") Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ТипЗнч(ОписаниеОбработчика.Обработчики) = Тип("Массив") Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого ТекОбработчик Из ОписаниеОбработчика.Обработчики Цикл
		ОбработатьДанные(Данные, ТекОбработчик);
	КонецЦикла;
	
КонецПроцедуры // ПродолжениеОбработкиДанных()

// Процедура - обратного вызова (callback) выполняет вызов завершение обработки данных для всех обработчиков
//
// Параметры:
//  ИдОбработчика    - Строка     - идентификатор обработчика
//
Процедура ЗавершениеОбработкиДанных(Знач ИдОбработчика) Экспорт
	
	ОписаниеОбработчика = АктивныеОбработчики.Получить(ИдОбработчика);
	
	Если НЕ ОписаниеОбработчика.Свойство("Обработчики") Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ТипЗнч(ОписаниеОбработчика.Обработчики) = Тип("Массив") Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого ТекОбработчик Из ОписаниеОбработчика.Обработчики Цикл
		ИнициализироватьОбработчикДанных(ТекОбработчик);
		ТекОбработчик.Обработка.ЗавершениеОбработкиДанных();
	КонецЦикла;
	
КонецПроцедуры // ЗавершениеОбработкиДанных()

#КонецОбласти // ПрограммныйИнтерфейс

#Область СлужебныеПроцедурыИФункции

// Процедура - создает внешнюю обработку в соответствии с указанными параметрами
//
// Параметры:
//  ОписаниеОбработчика              - Структура              - описание обработчика данных
//       *ПутьКОбработке             - Строка                 - путь к файлу внешней обработке
//       *ПроцедураОбработки         - Строка                 - имя процедуры обработки данных
//       *Параметры                  - Строка                 - структура параметров процедуры обработки данных
//           *<Имя параметра>        - Произвольный           - знаечние параметра процедуры обработки данных
//       *АдресОбработки             - Строка                 - адрес внешней обработки во временном хранилище
//       *ИмяОбработки               - Строка                 - имя внешней обработки после подключения
//       *Обработка                  - ВнешняяОбработкаОбъект - объект внешней обработки
//                                                              (заполняется в результате выполнения процедуры)
//       *Обработчики                - Массив(Структура)      - массив обработчиков данных,
//                                                              полученных от обработки текущего уровня
//                                                              (состав полей элемента аналогичен текущему уровню) 
//
Процедура ИнициализироватьОбработчикДанных(ОписаниеОбработчика)
	
	Если НЕ ОписаниеОбработчика.Свойство("Обработка") Тогда
	
		ИмяОбработки = Неопределено;
		ОписаниеОбработчика.Свойство("ИмяОбработки", ИмяОбработки);
	
		ОписаниеЗащиты = Новый ОписаниеЗащитыОтОпасныхДействий();
		ОписаниеЗащиты.ПредупреждатьОбОпасныхДействиях = Ложь;
	
		Если ОписаниеОбработчика.Свойство("АдресОбработки") Тогда
			ИмяОбработки = ВнешниеОбработки.Подключить(ОписаниеОбработчика.АдресОбработки,
			                                           ИмяОбработки,
			                                           Ложь,
			                                           ОписаниеЗащиты);
			                                           
			//@skip-warning
			ОписаниеОбработчика.Вставить("Обработка", ВнешниеОбработки.Создать(ИмяОбработки));
		Иначе
			//@skip-warning
			ОписаниеОбработчика.Вставить("Обработка", ВнешниеОбработки.Создать(ОписаниеОбработчика.ПутьКОбработке, Ложь));
		КонецЕсли;
		
		ОписаниеОбработчика.Обработка.ПриСозданииОбъекта(ЭтотОбъект);
				
		Если НЕ ТипЗнч(АктивныеОбработчики) = Тип("Соответствие") Тогда
			АктивныеОбработчики = Новый Соответствие();
		КонецЕсли;
		Если ОписаниеОбработчика.Свойство("ИдОбработчика") Тогда
			ИдОбработчика = ОписаниеОбработчика.ИдОбработчика;
		Иначе
			ИдОбработчика = СокрЛП(Новый УникальныйИдентификатор());
		КонецЕсли;
		
		ОписаниеОбработчика.Обработка.УстановитьИдентификатор(ИдОбработчика);
		АктивныеОбработчики.Вставить(ИдОбработчика, ОписаниеОбработчика);
			
	КонецЕсли;
	
	УстановитьПараметрыОбработчика(ОписаниеОбработчика);

КонецПроцедуры // ИнициализироватьОбработчикДанных()

// Процедура - устанавливает параметры обработки - обработчика данных
//
// Параметры:
//  ОписаниеОбработчика              - Структура              - описание обработчика данных
//       *ПутьКОбработке             - Строка                 - путь к файлу внешней обработке
//       *ПроцедураОбработки         - Строка                 - имя процедуры обработки данных
//       *Параметры                  - Строка                 - структура параметров процедуры обработки данных
//           *<Имя параметра>        - Произвольный           - знаечние параметра процедуры обработки данных
//       *ИмяОбработки               - Строка                 - имя внешней обработки после подключения
//       *Обработчики                - Массив(Структура)      - массив обработчиков данных,
//                                                              полученных от обработки текущего уровня
//                                                              (состав полей элемента аналогичен текущему уровню) 
//
Процедура УстановитьПараметрыОбработчика(Знач ОписаниеОбработчика)
	
	Если НЕ ОписаниеОбработчика.Свойство("Параметры") Тогда
		Возврат;
	КонецЕсли;

	Для Каждого ТекПараметр Из ОписаниеОбработчика.Параметры Цикл
		Если НЕ ТипЗнч(ТекПараметр.Значение) = Тип("Структура") Тогда
			Продолжить;
		КонецЕсли;
		Если НЕ (ТекПараметр.Значение.Свойство("ИмяОбработки")
		 ИЛИ ТекПараметр.Значение.Свойство("ИдОбработчика")) Тогда
			Продолжить;
		КонецЕсли;
		
		ОписаниеОбработчика.Параметры[ТекПараметр.Ключ] = ВычислитьЗначениеПараметра(ТекПараметр.Значение);
	КонецЦикла;
	
	ОписаниеОбработчика.Обработка.УстановитьПараметрыОбработкиДанных(ОписаниеОбработчика.Параметры);
	
КонецПроцедуры // УстановитьПараметрыОбработчика()

// Функция - вычисляет и возвращает значение параметра обработки - обработчика данных
// в случае, когда значение параметра вычисляется в обработке
//
// Параметры:
//  ОписаниеПараметра                - Структура              - описание механизма получения значения параметра
//       *ПутьКОбработке             - Строка                 - путь к файлу внешней обработке
//       *ИмяОбработки               - Строка                 - имя подключенной внешней обработке
//       *Обработка                  - ВнешняяОбработкаОбъект - объект внешней обработки
//                                                              (заполняется в результате выполнения процедуры)
//       *ФункцияПолученияЗначения   - Строка                 - имя функции получения значения параметра
//
// Возвращаемое значение:
//  Произвольный              - значение параметра
//
Функция ВычислитьЗначениеПараметра(Знач ОписаниеПараметра)
	
	Если НЕ ОписаниеПараметра.Свойство("ФункцияПолученияЗначения") Тогда
		ОписаниеПараметра.Вставить("ФункцияПолученияЗначения", "РезультатОбработки");
	КонецЕсли;
		
	ЗначениеПараметра = Неопределено;
		
	Если ОписаниеПараметра.Свойство("ИдОбработчика") Тогда
		
		//@skip-warning
		ТекОбработчик = АктивныеОбработчики.Получить(ОписаниеПараметра.ИдОбработчика);
		
	ИначеЕсли ОписаниеПараметра.Свойство("ИмяОбработки") Тогда
		
		Если НЕ ОписаниеПараметра.Свойство("Обработка") Тогда
			ОписаниеПараметра.Вставить("Обработка");
		КонецЕсли;
		
		Если ОписаниеПараметра.Обработка = Неопределено Тогда
			ОписаниеПараметра.Обработка = ВнешниеОбработки.Создать(ОписаниеПараметра.ИмяОбработки, Ложь);
		КонецЕсли;
		
		УстановитьПараметрыОбработчика(ОписаниеПараметра);
		
		ТекОбработчик = ОписаниеПараметра;
	
	Иначе
		Возврат Неопределено;
	КонецЕсли;
	
	Выполнить(СтрШаблон("ЗначениеПараметра = ТекОбработчик.Обработка.%1()", ОписаниеПараметра.ФункцияПолученияЗначения));
	
	Возврат ЗначениеПараметра;
	
КонецФункции // ВычислитьЗначениеПараметра()

// Функция - проверяет тип значения на соответствие допустимым типам
//
// Параметры:
//  Значение             - Произвольный                 - проверяемое значение
//  ДопустимыеТипы       - Строка, Массив(Строка, Тип)  - список допустимых типов
//  ШаблонТекстаОшибки   - Строка                       - шаблон строки сообщения об ошибке
//                                                        ("Некорректный тип значения ""%1"" ожидается тип %2")
// 
// Возвращаемое значение:
//	Булево       - Истина - проверка прошла успешно
//
Функция ПроверитьДопустимостьТипа(Знач Значение, Знач ДопустимыеТипы, Знач ШаблонТекстаОшибки = "")
	
	ТипЗначения = ТипЗнч(Значение);
	
	Если ТипЗнч(ДопустимыеТипы) = Тип("Строка") Тогда
		МассивДопустимыхТипов = СтрРазделить(ДопустимыеТипы, ",");
	ИначеЕсли ТипЗнч(ДопустимыеТипы) = Тип("Массив") Тогда
		МассивДопустимыхТипов = ДопустимыеТипы;
	Иначе
		ВызватьИсключение СтрШаблон("Некорректно указан список допустимых типов, тип ""%1"" ожидается тип %2!",
		                            Тип(ДопустимыеТипы),
									"""Строка"" или ""Массив""");
	КонецЕсли;
	
	Типы = Новый Соответствие();
	
	СтрокаДопустимыхТипов = "";
	
	Для Каждого ТекТип Из МассивДопустимыхТипов Цикл
		ВремТип = ?(ТипЗнч(ТекТип) = Тип("Строка"), Тип(СокрЛП(ТекТип)), ТекТип);
		Типы.Вставить(ВремТип, СокрЛП(ТекТип));
		Если НЕ СтрокаДопустимыхТипов = "" Тогда
			СтрокаДопустимыхТипов = СтрокаДопустимыхТипов +
				?(МассивДопустимыхТипов.Найти(ТекТип) = МассивДопустимыхТипов.ВГраница(), " или ", ", ");
		КонецЕсли;
	КонецЦикла;
	
	Если ШаблонТекстаОшибки = "" Тогда
		ШаблонТекстаОшибки = "Некорректный тип значения ""%1"" ожидается тип %2!";
	КонецЕсли;
	
	Если Типы[ТипЗначения] = Неопределено Тогда
		ВызватьИсключение СтрШаблон(ШаблонТекстаОшибки, СокрЛП(ТипЗначения), СтрокаДопустимыхТипов);
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции // ПроверитьДопустимостьТипа()

// Функция - обработчик чтения значений из JSON
//
// Параметры:
//  Свойство                  - Строка         - имя прочитанного свойства
//  Значение                  - Произвольный   - прочитанное значение / результат обработки
//  ДополнительныеПараметры   - Произвольный   - дополнительные параметры обработки
// 
// Возвращаемое значение:
//	Произвольный       - результат обработки
//
Функция ОбработчикЧтенияПараметровИзJSON(Свойство, Значение, ДополнительныеПараметры) Экспорт
	
	Если ТипЗнч(Значение) = Тип("Строка") Тогда
		Для Каждого ТекРабочийКаталог Из РабочиеКаталоги Цикл
			Значение = СтрЗаменить(Значение, ТекРабочийКаталог.Ключ, ТекРабочийКаталог.Значение);
		КонецЦикла;
	КонецЕсли;
	
	Возврат Значение;
	
КонецФункции // ОбработчикЧтенияПараметровИзJSON()

// Функция - возвращает версию обработчика
// 
// Возвращаемое значение:
// 	Строка - версия обработчика
//
Функция Версия() Экспорт
	
	Возврат ЭтотОбъект.ПолучитьМакет("ВерсияОбработки").ПолучитьТекст();
	
КонецФункции // Версия()

#КонецОбласти // СлужебныеПроцедурыИФункции
