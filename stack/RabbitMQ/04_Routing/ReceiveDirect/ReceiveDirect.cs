using System;
using System.Text;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;

class ReceiveDirect
{
    public static void Main(string[] args)
    {
        // create factory, connection and channel
        var factory = new ConnectionFactory() { HostName = "localhost" };
        using (var connection = factory.CreateConnection())
        using (var channel = connection.CreateModel())
        {

            // set exchange and queue relationships
            channel.ExchangeDeclare(exchange: "direct_logs", type: "direct");

            // temporary randomly assigned queue connected to life-time of consumer
            var queueName = channel.QueueDeclare().QueueName;

            if (args.Length < 1)
            {
                Console.WriteLine("Usage: {0} [info] [warning] [error]",
                                  Environment.GetCommandLineArgs()[0]);
                Console.WriteLine("Press [enter] to exit");
                Console.ReadLine();
                Environment.ExitCode = 1;
                return;
            }

            foreach (var severity in args)
            {
                channel.QueueBind(queue: queueName,
                                  exchange: "direct_logs",
                                  routingKey: severity);
            }

            Console.WriteLine("Waiting for messages:");

            // create consumer event handler
            var consumer = new EventingBasicConsumer(channel);
            consumer.Received += (model, ea) =>
            {
                var body = ea.Body;
                var message = Encoding.UTF8.GetString(body);
                var routingKey = ea.RoutingKey;
                Console.WriteLine("[x] Recieved '{0}':'{1}'",
                                   routingKey, message);
            };

            // consume messages
            channel.BasicConsume(queue: queueName,
                                autoAck: true,
                                consumer: consumer);

            Console.WriteLine("Press [enter] to exit");
            Console.ReadLine();

        }

    }
}


