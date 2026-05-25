# 定义"人类"这个模板（类）
class Person:
    def __init__(self, name, age):
        self.name = name  
        self.age = age    
    
    def hello(self):
        print(f"你好，我叫{self.name}，今年{self.age}岁")

p1 = Person("小明", 20)  
p2 = Person("小红", 18)  

p1.hello()  
p2.hello()  