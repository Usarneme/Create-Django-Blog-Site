#!bin/bash

echo -n "Enter the app name (no spaces or special chars, please). eg: django_blog"
read NAME
echo -n "Enter the virtual environment name (no spaces or special chars, please). eg: myvenv"
read VENV

# define a newline to input where needed in sed replace commands
NL='
'

# conditional, test whether name was provided
if [[ -n $NAME ]]
then
  echo "CREATING DJANGO POWERED BLOG PROJECT: $NAME (NOTE: 21 STEPS TOTAL)"
  echo "1. Setting up virtual environment"
  python3 -m venv $VENV
  source $VENV/bin/activate
  echo "1. Done"

  echo "2. Creating requirements.txt file for project dependencies"
  echo "Django~=2.2.4" >> requirements.txt
  echo "2. Done"

  echo "3. Installing Django dependency"
  pip install -r requirements.txt
  echo "3. Done"

  echo "4. Building Django project"
  django-admin startproject mysite .
  echo "4. Done"

  echo "5. Adding TIME ZONE America/Los_Angeles to mysite/settings.py"
  echo "TIME_ZONE = 'America/Los_Angeles'" >> mysite/settings.py
  echo "5. Done"

  echo "6. Adding static root to mysite/settings.py"
  echo "STATIC_ROOT = os.path.join(BASE_DIR, 'static')" >> mysite/settings.py
  echo "6. Done"

  echo "7. Updating allowed hosts to include localhost"
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then # Linux
    sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = ['localhost']/g" mysite/settings.py
  elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OSX
    sed -i '' "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = ['localhost']/g" mysite/settings.py
  fi
  echo "7. Done"

  echo "8. Creating first sqlite3 database migration"
  python manage.py migrate
  echo "8. Done"

  echo "9. Creating $NAME project"
  python manage.py startapp $NAME
  echo "9. Done"

  echo "10. Updating Installed Apps in mysite/settings.py"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then # Linux
    sed -i "s/'django.contrib.staticfiles',/'django.contrib.staticfiles',\\$NL    'blog.apps.BlogConfig',/g" mysite/settings.py
  elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OSX
    sed -i '' "s/'django.contrib.staticfiles',/'django.contrib.staticfiles',\\$NL    'blog.apps.BlogConfig',/g" mysite/settings.py
  fi
  echo "10. Done"

  echo "11. Creating blog model"
  rm $NAME/models.py
  echo "from django.conf import settings
from django.db import models
from django.utils import timezone


class Post(models.Model):
    author = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    title = models.CharField(max_length=200)
    text = models.TextField()
    created_date = models.DateTimeField(default=timezone.now)
    published_date = models.DateTimeField(blank=True, null=True)

    def publish(self):
        self.published_date = timezone.now()
        self.save()

    def __str__(self):
        return self.title" >> $NAME/models.py
  echo "11. Done"

  echo "12. Updating database migration"
  python manage.py makemigrations $NAME
  python manage.py migrate $NAME
  echo "12. Done"

  echo "13. Rewriting $NAME/admin.py to allow administration actions"
  rm $NAME/admin.py
  echo "from django.contrib import admin
from .models import Post

admin.site.register(Post)" >> $NAME/admin.py
  echo "13. Done"

  echo "14. Rewriting mysite/urls.py to handle admin routes"
  rm mysite/urls.py
  echo "from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('$NAME.urls')),
]" >> mysite/urls.py
  echo "14. Done"

  echo "15. Generating templates and statics folders"
  mkdir $NAME/templates
  mkdir $NAME/templates/blog
  mkdir $NAME/static
  mkdir $NAME/static/css
  echo "15. Done"

  echo "16. Generating template html and css files"
  touch $NAME/static/css/blog.css
  echo "{% load static %}
<!DOCTYPE html>
<html>

<head>
  <title>Blog Home</title>
  <link rel=\"stylesheet\" href=\"{% static 'css/blog.css' %}\">
</head>

<body>
  <header class=\"page-header\">
    <div class=\"container\">
      <nav>
        {% if user.is_authenticated %}
          <a href=\"{% url 'post_new' %}\" class=\"top-menu\">
            {% include './icons/file-plus.svg' %} Add Post
          </a>
        {% endif %}
        <a href=\"/admin\" class=\"top-menu\">Admin</a>
      </nav>
      <h1><a href=\"/\">Django Blog</a></h1>
    </div>
  </header>
  <main>
    {% block content %}
    {% endblock %}
  </main>
</body>
</html>" >> $NAME/templates/blog/base.html
  echo "{% extends 'blog/base.html' %}

{% block content %}
<article class=\"post\">
  <aside class=\"actions\">
    {% if user.is_authenticated %}
      <a class=\"btn btn-default\" href=\"{% url 'post_edit' pk=post.pk %}\">
        {% include './icons/pencil.svg' %} Edit Post
      </a>
    {% endif %}
  </aside>
  {% if post.published_date %}
  <time class=\"date\">
    {{ post.published_date }}
  </time>
  {% endif %}
  <h2>{{ post.title }}</h2>
  <p>{{ post.text|linebreaksbr }}</p>
</article>
{% endblock %}" >> $NAME/templates/blog/post_detail.html
  echo "{% extends 'blog/base.html' %}

{% block content %}
<h2>New post</h2>
<form method=\"POST\" class=\"post-form\">{% csrf_token %}
  {{ form.as_p }}
  <button type=\"submit\" class=\"save btn btn-default\">Save</button>
</form>
{% endblock %}" >> $NAME/templates/blog/post_edit.html
  echo "{% extends 'blog/base.html' %}

{% block content %}
  {% for post in posts %}
    <article style=\"border: 2px solid slategray; margin: 22px; padding: 11px; background: rgba(255,255,255,0.6);\">
      <time>published: {{ post.published_date }}</time>
      <h2><a href=\"{% url 'post_detail' pk=post.pk %}\">{{ post.title }}</a></h2>
      <p>{{ post.text|linebreaksbr }}</p>
    </article>
  {% endfor %}
{% endblock %}" >> $NAME/templates/blog/post_list.html
  echo "16. Done"

  echo "17. Generating forms and viewmodel"
  touch $NAME/forms.py
  echo "from django import forms
from .models import Post


class PostForm(forms.ModelForm):

    class Meta:
        model = Post
        fields = ('title', 'text',)" >> $NAME/forms.py
  echo "17. Done"

  echo "18. Generating $NAME/urls.py file"
  echo "from django.urls import path
from . import views

urlpatterns = [
    path('', views.post_list, name='post_list'),
    path('post/<int:pk>/', views.post_detail, name='post_detail'),
    path('post/new/', views.post_new, name='post_new'),
    path('post/<int:pk>/edit/', views.post_edit, name='post_edit'),
]" >> $NAME/urls.py
  echo "Done."

  echo "19. Generating $NAME/views.py"
  echo "from django.shortcuts import get_object_or_404, render, redirect
from django.utils import timezone
from .models import Post
from .forms import PostForm


def post_list(request):
    posts = Post.objects.filter(published_date__lte=timezone.now()
                                ).order_by('published_date')
    return render(request, 'blog/post_list.html', {'posts': posts})


def post_detail(request, pk):
    post = get_object_or_404(Post, pk=pk)
    return render(request, 'blog/post_detail.html', {'post': post})


def post_new(request):
    if request.method == \"POST\":
        form = PostForm(request.POST)
        if form.is_valid():
            post = form.save(commit=False)
            post.author = request.user
            post.published_date = timezone.now()
            post.save()
            return redirect('post_detail', pk=post.pk)
    else:
        form = PostForm()
    return render(request, 'blog/post_edit.html', {'form': form})


def post_edit(request, pk):
    post = get_object_or_404(Post, pk=pk)
    if request.method == \"POST\":
        form = PostForm(request.POST, instance=post)
        if form.is_valid():
            post = form.save(commit=False)
            post.author = request.user
            post.published_date = timezone.now()
            post.save()
            return redirect('post_detail', pk=post.pk)
    else:
        form = PostForm(instance=post)
    return render(request, 'blog/post_edit.html', {'form': form})" >> $NAME/views.py
  echo "19. Done"

  echo "20. Creating icons folder and svg files"
  mkdir $NAME/templates/blog/icons
  echo "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"16\" height=\"16\" fill=\"currentColor\" class=\"bi bi-file-earmark-plus\" viewBox=\"0 0 16 16\">
  <path d=\"M8 6.5a.5.5 0 0 1 .5.5v1.5H10a.5.5 0 0 1 0 1H8.5V11a.5.5 0 0 1-1 0V9.5H6a.5.5 0 0 1 0-1h1.5V7a.5.5 0 0 1 .5-.5z\"/>
  <path d=\"M14 4.5V14a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V2a2 2 0 0 1 2-2h5.5L14 4.5zm-3 0A1.5 1.5 0 0 1 9.5 3V1H4a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1V4.5h-2z\"/>
</svg>" >> $NAME/templates/blog/icons/file-plus.svg
  echo "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"16\" height=\"16\" fill=\"currentColor\" class=\"bi bi-pencil-fill\" viewBox=\"0 0 16 16\">
  <path d=\"M12.854.146a.5.5 0 0 0-.707 0L10.5 1.793 14.207 5.5l1.647-1.646a.5.5 0 0 0 0-.708l-3-3zm.646 6.061L9.793 2.5 3.293 9H3.5a.5.5 0 0 1 .5.5v.5h.5a.5.5 0 0 1 .5.5v.5h.5a.5.5 0 0 1 .5.5v.5h.5a.5.5 0 0 1 .5.5v.207l6.5-6.5zm-7.468 7.468A.5.5 0 0 1 6 13.5V13h-.5a.5.5 0 0 1-.5-.5V12h-.5a.5.5 0 0 1-.5-.5V11h-.5a.5.5 0 0 1-.5-.5V10h-.5a.499.499 0 0 1-.175-.032l-.179.178a.5.5 0 0 0-.11.168l-2 5a.5.5 0 0 0 .65.65l5-2a.5.5 0 0 0 .168-.11l.178-.178z\"/>
</svg>" >> $NAME/templates/blog/icons/pencil.svg
  echo "20. Done"

  echo "21. Create a superuser to administrate the newly-created blog"
  python manage.py createsuperuser &&
  echo "21. Done"

  echo "ALL DONE. EXITING."
  echo
  echo "To start the project"
  echo "first run ~ source $VENV/bin/activate"
  echo "then run ~ python manage.py runserver"
  echo "Then open your browser to localhost:8000"

else
  echo "You must provide a name. Please try again."
  exit 0
fi