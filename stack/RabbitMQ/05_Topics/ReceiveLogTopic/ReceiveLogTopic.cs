using System;
using System.Text;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;

namespace ReceiveLogTopic
{
    class RecieveLogTopic
    {
        static void Main(string[] args)
        {
            // create factory
            var factory = new ConnectionFactory() { HostName = "localhost" };
            using(var connection = factory.CreateConnection())
            using(var channel = connection.CreateModel())
            {
                // declare the exchange
                channel.ExchangeDeclare(exchange: "topic_logs",
                                        type: "topic");

                // set queue to random name and to lifetime of consumer
                var queueName = channel.QueueDeclare().QueueName;

                if(args.Length < 1)
                {
                    Console.Error.WriteLine("Usage: {0} [binding_key...]",
                                            Environment.GetCommandLineArgs()[0]);
                    Console.WriteLine("Press [enter] to exit.");
                    Console.ReadLine();
                    Environment.ExitCode = 1;
                    return;
                }

                // for each bindingkey bind to a particular queue
                foreach (var bindingKey in args)
                {
                    channel.QueueBind(queue: queueName,
                                      exchange: "topic_logs",
                                      routingKey: bindingKey);
                }

                Console.WriteLine("[*] Wating for messages. To exit press CRTL+C");

                // create consumers
                var consumer = new EventingBasicConsumer(channel);

                // create event handler
                consumer.Received += (model, ea) =>
                {
                    var body = ea.Body;
                    var message = Encoding.UTF8.GetString(body);
                    var routingKey = ea.RoutingKey;

                    Console.WriteLine(" [x] Received '{0}','{1}'",
                                      routingKey,
                                      message);
                };

                // consume the message
                channel.BasicConsume(queue: queueName,
                                     autoAck: true,
                                     consumer: consumer);

                Console.WriteLine("Press [enter] to exit");
                Console.ReadLine();

            }

        }
    }
}
