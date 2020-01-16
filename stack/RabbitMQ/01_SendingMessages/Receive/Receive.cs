using System;
using System.Text;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;


namespace Receive
{
    class Receive
    {
        public static void Main()
        {
            // setup factory, connection and channel objects
            var factory = new ConnectionFactory() { HostName = "localhost" };
            using (var conection = factory.CreateConnection())
            {
                using (var channel = conection.CreateModel())
                {
                    // declare queue here as well
                    channel.QueueDeclare(queue: "hello",
                                         durable: false,
                                         exclusive: false,
                                         autoDelete: false,
                                         arguments: null);

                    // create an event consumer
                    var consumer = new EventingBasicConsumer(channel);

                    // setup callback
                    consumer.Received += (model, ea) =>
                    {
                        var body = ea.Body;
                        var message = Encoding.UTF8.GetString(body);
                        Console.WriteLine("[x] Received {0}", message);
                    };

                    // cosnume the message and print
                    channel.BasicConsume(queue: "hello",
                                        autoAck: true,
                                        consumer: consumer);
                    Console.WriteLine("Press [enter] to exit");
                    Console.ReadLine();
                
                }
            }
        }
    }
}
