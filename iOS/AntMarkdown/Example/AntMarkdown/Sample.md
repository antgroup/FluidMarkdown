观察者模式是一种行为设计模式，允许你定义一个订阅机制，可以在对象事件发生时通知多个“观察”该对象的其他对象。下面是一个简单的 Java 实现示例：

定义观察者接口

```java
public interface Observer {
    void update(String message);
}
```

定义被观察者接口

```java
import java.util.ArrayList;
import java.util.List;

public class Subject {
    private List<Observer> observers = new ArrayList<>();
    private String state;

    public void attach(Observer observer) {
        observers.add(observer);
    }

    public void detach(Observer observer) {
        observers.remove(observer);
    }

    public void notifyObservers() {
        for (Observer observer : observers) {
            observer.update(state);
        }
    }

    public void setState(String state) {
        this.state = state;
        notifyObservers();
    }
}
```

### 3. 实现观察者
```java
public class ConcreteObserver implements Observer {
    private String name;

    public ConcreteObserver(String name) {
        this.name = name;
    }

    @Override
    public void update(String message) {
        System.out.println(name + \" received: \" + message);
    }
}
```

### 4. 使用示例
```java
public class ObserverPatternDemo {
    public static void main(String[] args) {
        Subject subject = new Subject();

        Observer observer1 = new ConcreteObserver(\"Observer 1\");
        Observer observer2 = new ConcreteObserver(\"Observer 2\");

        subject.attach(observer1);
        subject.attach(observer2);

        subject.setState(\"First state change\");
        subject.detach(observer1);

        subject.setState(\"Second state change\");
    }
}
```

### 说明
- `Subject` 类是被观察者，它维护一个观察者列表，并提供添加、删除和通知观察者的方法。
- `Observer` 接口定义了更新方法，具体观察者类实现该接口。
- 在 `ObserverPatternDemo` 类中，创建了 `Subject` 实例和两个 `Observer` 实例，通过 `attach` 方法将观察者添加到被观察者中，当被观察者的状态改变时，会调用 `notifyObservers` 方法通知所有观察者。

请注意，实际应用中可能需要根据具体需求进行扩展和优化。
