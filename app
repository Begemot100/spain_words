import random
import os
from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.label import Label
from kivy.uix.button import Button
from kivy.uix.textinput import TextInput
from kivy.uix.popup import Popup
from kivy.utils import get_color_from_hex
from playsound import playsound
from kivy.core.window import Window


class SpainWords(App):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.dictionary = {}
        self.spanish_words = []
        self.correct_count = 0
        self.incorrect_count = 0
        self.current_word_index = 0

        self.correct_label = Label(text=f'[color=#D3D3D3]Правильные ответы: {self.correct_count}[/color]',
                                   markup=True, size_hint=(0.8, 0.1), pos_hint={'center_x': 0.5, 'center_y': 0.8})
        self.incorrect_label = Label(text=f'[color=#D3D3D3]Неправильные ответы: {self.incorrect_count}[/color]',
                                     markup=True, size_hint=(0.8, 0.1), pos_hint={'center_x': 0.5, 'center_y': 0.9})

    def load_dictionary(self):
        file_path = os.path.join(os.getcwd(), '/Users/begemot/Downloads/Git/Spain_words/spain.txt')  # Assuming the file is in the same directory
        with open(file_path, 'r', encoding='utf-8') as file:
            for line in file:
                line = line.strip()
                if line:
                    word, translation = line.split(':')
                    self.dictionary[word.strip()] = translation.strip()

        self.spanish_words = list(self.dictionary.keys())
        random.shuffle(self.spanish_words)

    def update_word(self):
        if self.current_word_index < len(self.spanish_words):
            word = self.spanish_words[self.current_word_index]
            self.label.text = f'[color=#D3D3D3][b]Слово:[/b][/color] {word}'
            self.current_word_index += 1
        else:
            self.show_summary_popup()

    def check_translation(self):
        user_translation = self.text_input.text.strip()
        correct_translation = self.dictionary[self.spanish_words[self.current_word_index - 1]]

        if user_translation.lower() == correct_translation.lower():
            self.correct_count += 1
            playsound('correct_sound.mp3')
        else:
            self.incorrect_count += 1
            playsound('incorrect_sound.mp3')
            self.show_error_popup(correct_translation)

        self.text_input.text = ''
        self.update_word()

        self.correct_label.text = f'[color=#D3D3D3]Правильные ответы: {self.correct_count}[/color]'
        self.incorrect_label.text = f'[color=#D3D3D3]Неправильные ответы: {self.incorrect_count}[/color]'

        self.check_button.disabled = True
        self.text_input.focus = True

    def show_error_popup(self, correct_translation):
        popup_content = BoxLayout(orientation='vertical')
        error_label = Label(text='Ошибка')
        correct_answer_label = Label(text=f'Правильный ответ: {correct_translation}')

        popup_content.add_widget(error_label)
        popup_content.add_widget(correct_answer_label)

        popup = Popup(title='', content=popup_content, size_hint=(0.8, 0.4))
        popup.open()

    def finish_learning(self):
        self.show_summary_popup()

    def on_text_input(self, instance, value):
        self.check_button.disabled = not bool(value)

    def show_summary_popup(self):
        popup_content = BoxLayout(orientation='vertical')
        summary_label = Label(text='Изучение испанских слов завершено.')
        summary_label.bind(size=summary_label.setter('text_size'))

        summary_layout = BoxLayout(orientation='vertical')
        summary_layout.add_widget(summary_label)
        summary_layout.add_widget(self.incorrect_label)

        popup_content.add_widget(summary_layout)

        popup = Popup(title='Результаты', content=popup_content, size_hint=(0.8, 0.8))
        popup.open()

    def build(self):
        self.load_dictionary()
        Window.size = (300, 400)
        Window.clearcolor = get_color_from_hex('#3D3D3D')

        layout = BoxLayout(orientation='vertical')

        self.label = Label(text='[color=#D3D3D3][b]Слово:[/b][/color]', markup=True, font_size=36,
                           size_hint=(1, 0.2), pos_hint={'center_x': 0.5})

        self.text_input = TextInput(multiline=False, hint_text=' напишите ваш ответ',
                                    size_hint=(0.55, 0.05), pos_hint={'center_x': 0.5})
        self.text_input.bind(text=self.on_text_input)
        self.text_input.background_color = get_color_from_hex('#D3D3D3')
        self.text_input.background_normal = ''
        self.text_input.padding = [10, 10, 10, 10]

        self.check_button = Button(text='Проверить', size_hint=(0.4, 0.05),
                                   pos_hint={'center_x': 0.5, 'center_y': 1}, on_release=lambda x: self.check_translation())
        self.check_button.background_color = get_color_from_hex('#81D8D0')
        self.check_button.border_radius = [20, 20, 20, 20]

        self.finish_button = Button(text='Завершить', size_hint=(0.4, 0.05),
                                    pos_hint={'center_x': 0.5, 'center_y': 2}, on_release=lambda x: self.finish_learning())
        self.finish_button.background_color = get_color_from_hex('#D3D3D3')
        self.finish_button.border_radius = [20, 20, 20, 20]

        layout.add_widget(self.label)
        layout.add_widget(self.text_input)
        layout.add_widget(self.check_button)
        layout.add_widget(self.correct_label)
        layout.add_widget(self.incorrect_label)
        layout.add_widget(self.finish_button)

        self.update_word()

        return layout


if __name__ == '__main__':
    SpainWords().run()
