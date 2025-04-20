python -m venv .venv

source .venv/bin/activate

pip install rasa

pip install transformers

rasa --version

rasa init

echo 'language: ru

pipeline:
- name: WhitespaceTokenizer                # Токенизатор, разделяющий текст по пробелам
- name: RegexFeaturizer                    # Извлечение признаков с помощью регулярных выражений
- name: LexicalSyntacticFeaturizer         # Лексико-синтаксический анализатор
- name: CountVectorsFeaturizer             # Извлечение признаков по частоте слов
  analyzer: "char_wb"                      # Символьные N-граммы
  min_ngram: 1
  max_ngram: 2                             # Уменьшены размеры N-грамм для ускорения

# Подключение предобученной модели трансформера (BERT)
- name: "LanguageModelFeaturizer"
  model_name: "bert"                       # Модель BERT для русского языка
  model_weights: "bert-base-cased"          # Весы модели BERT
  cache_dir: null

- name: DIETClassifier                      # Классификатор на базе DIET
  epochs: 100                                 # Минимальное количество эпох обучения
  transformer_size: 32                      # Минимальный размер слоя трансформера
  number_of_transformer_layers: 1           # Один слой трансформера
  use_masked_language_model: false          # Отключено для ускорения
  batch_strategy: "balanced"
  hidden_layers_sizes:
    text: [32]                              # Минимальные скрытые слои

- name: EntitySynonymMapper                 # Маппер синонимов сущностей
- name: ResponseSelector                    # Минимальный выбор ответа
  epochs: 100                                 # Минимальное количество эпох обучения

policies:
  - name: MemoizationPolicy
    max_history: 2                          # Минимальная история
  - name: RulePolicy
  - name: TEDPolicy
    max_history: 2                          # Минимальное количество шагов в истории
    epochs: 100                               # Минимальное количество эпох обучения
    constrain_similarities: true' > config.yml


echo 'version: "3.1"

nlu:
  - intent: greet
    examples: |
      - Привет
      - Здравствуйте
      - Добрый день

  - intent: goodbye
    examples: |
      - До свидания
      - Пока
      - Увидимся

  - intent: ask_architecture
    examples: |
      - Расскажите об архитектуре ПО
      - Какие подходы существуют в архитектуре?
      - Что такое микросервисная архитектура?
      - Как выбрать архитектуру ПО?

  - intent: affirm
    examples: |
      - Да
      - Верно
      - Именно

  - intent: deny
    examples: |
      - Нет
      - Не нужно
      - Неверно

  - intent: request_info
    examples: |
      - Расскажите больше об этом
      - Можете уточнить?
      - Какие есть детали?' > data/nlu.yml


echo 'version: "3.1"

rules:
  - rule: Say hello
    steps:
      - intent: greet
      - action: utter_greet

  - rule: Say goodbye
    steps:
      - intent: goodbye
      - action: utter_goodbye

  - rule: Answer architecture questions
    steps:
      - intent: ask_architecture
      - action: utter_architecture_response

  - rule: Request additional information
    steps:
      - intent: request_info
      - action: utter_ask_more' > data/rules.yml

echo 'version: "3.1"

stories:
  - story: greet and ask architecture
    steps:
      - intent: greet
      - action: utter_greet
      - intent: ask_architecture
      - action: utter_architecture_response

  - story: goodbye
    steps:
      - intent: goodbye
      - action: utter_goodbye

  - story: ask for more info
    steps:
      - intent: request_info
      - action: utter_ask_more' > data/stories.yml

echo 'version: "3.1"

intents:
  - greet
  - goodbye
  - inform
  - ask_architecture
  - affirm
  - deny
  - request_info

responses:
  utter_greet:
    - text: "Привет! Чем могу помочь в области архитектуры программного обеспечения?"
  
  utter_goodbye:
    - text: "До свидания! Если появятся вопросы по архитектуре ПО, обращайтесь."
  
  utter_ask_more:
    - text: "Что именно вас интересует в архитектуре программного обеспечения?"
  
  utter_acknowledge:
    - text: "Понял, расскажите подробнее о вашем проекте или задачах."

  utter_architecture_response:
    - text: "Архитектура ПО включает выбор структур, которые обеспечивают масштабируемость, гибкость и поддерживаемость приложения. Задайте конкретный вопрос по этой теме, и я помогу вам с информацией."

entities:
  - topic

slots:
  topic:
    type: text
    influence_conversation: false
    mappings:
        - type: from_text

session_config:
  session_expiration_time: 60
  carry_over_slots_to_new_session: true' > domain.yml


rasa train
