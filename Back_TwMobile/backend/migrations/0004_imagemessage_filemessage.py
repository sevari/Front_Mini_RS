# Generated by Django 4.2.13 on 2024-06-22 14:05

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('backend', '0003_remove_message_is_read_and_more'),
    ]

    operations = [
        migrations.CreateModel(
            name='ImageMessage',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('image', models.ImageField(upload_to='images/')),
                ('message', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='images', to='backend.message')),
            ],
        ),
        migrations.CreateModel(
            name='FileMessage',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('file', models.FileField(upload_to='files/')),
                ('message', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='files', to='backend.message')),
            ],
        ),
    ]