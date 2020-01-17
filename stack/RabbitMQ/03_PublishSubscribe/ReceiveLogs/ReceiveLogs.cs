using System;
using System.Text;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;

// implements the consumer side of the "publish/subsribe" model
// a temporary queue is declared to exist only during the lifetime of the consumer
// any messages sent from the producer before the consumer is active will be lost
// a binding is needed between the exchange and the queue



class ReceiveLogs
{
    public static void Main(string[] args)
    {

        var factory = new ConnectionFactory() { HostName = "localhost" };
        using(var connection = factory.CreateConnection())
        using(var channel = connection.CreateModel())
        {
            channel.ExchangeDeclare(exchange: "logs", type: ExchangeType.Fanout);

            // declare a random (temporary) queue
            var queue = channel.QueueDeclare().QueueName;

            // create binding between exchange and queue
            channel.QueueBind(queue: queue,
                              exchange: "logs",
                              routingKey: "");

            // create the callback for the consumer(s)

            var consumer = new EventingBasicConsumer(channel);
            consumer.Received += (model, ea) =>
            {
                var body = ea.Body;
                var message = Encoding.UTF8.GetString(body);
                Console.WriteLine("[x] {0}", message);
            };

            // consume the messages
            channel.BasicConsume(queue: queue, 
                                 autoAck: true, 
                                 consumer: consumer);

            Console.WriteLine("Press [enter] to exit");
            Console.ReadLine();
                              
        }

    }
}
