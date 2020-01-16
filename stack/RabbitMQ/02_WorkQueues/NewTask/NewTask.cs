using System;
using RabbitMQ.Client;
using System.Text;


    class NewTask
    {
        public static void Main(string[] args)
        {
            var factory = new ConnectionFactory() { HostName = "localhost" };

            // initilaize a connection
            using (var connection = factory.CreateConnection())
            {
                // create a channel
                using (var channel = connection.CreateModel())
                {
                    channel.QueueDeclare(queue: "queue_tasks",
                                         durable: true, // set queue to be durable - even if RMQ crashes they will not be lost
                                         exclusive: false,
                                         autoDelete: false,
                                         arguments: null);

                    // create message and contents
                    var message = GetMessage(args);
                    var body = Encoding.UTF8.GetBytes(message);

                    var properties = channel.CreateBasicProperties();
                    properties.Persistent = true; // messages marked as persistent - even if RMQ crashes they will not be lost

                    // don't send more than one message to a consumer
                    // until acknowledged otherwise send to next available worker
                    channel.BasicQos(0, 1, false);

                    channel.BasicPublish(exchange: "",
                                         routingKey: "queue_tasks",
                                         basicProperties: properties,
                                         body: body);

                Console.WriteLine("[x] Sent {0}", message);

                }

            // wait for user input
            Console.WriteLine("press [enter] to exit.");
            Console.ReadLine();

            }
        }

        private static string GetMessage(string[] args)
        {
        return ((args.Length > 0) ? string.Join(" ", args) : "Hello World!");
        }

    }

    

