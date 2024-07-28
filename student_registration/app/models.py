from django.db import models


class Student(models.Model):
    name = models.CharField(max_length=100)
    dob = models.DateField()
    father_name = models.CharField(max_length=100)
    address = models.TextField()
    student_class = models.IntegerField()
    percentage_10th = models.FloatField()
    marksheet_pdf = models.FileField(upload_to="marksheets/")

    def __str__(self):
        return self.name
