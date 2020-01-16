using System;
using System.Text;
using System.Threading;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;



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
                    channel.QueueDeclare(queue: "queue_tasks",
                                         durable: true, // set queue to durable so even if RabbitMQ crashes it won't be lost
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

                        // simulate doing a task
                        int dots = message.Split('.').Length - 1;
                        Thread.Sleep(dots * 1000);

                        Console.WriteLine("[x] Done");
                        channel.BasicAck(deliveryTag: ea.DeliveryTag, multiple: false);
                    };

                    // cosnume the message and print
                    channel.BasicConsume(queue: "queue_tasks",
                                        autoAck: false,
                                        consumer: consumer);
                    Console.WriteLine("Press [enter] to exit");
                    Console.ReadLine();
                
                }
            }
        }
    }

