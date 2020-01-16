using System;
using RabbitMQ.Client;
using System.Text;


namespace Send
{
    class Send
    {
        public static void Main()
        {
            // create a fresh instance of a factory
            var factory = new ConnectionFactory() { HostName = "localhost" };
            // create a connection
            using (var connection = factory.CreateConnection())
            {
                // create a fresh channel
                using (var channel = connection.CreateModel())
                {
                    // declare queue for outgoing message
                    channel.QueueDeclare(queue: "hello",
                                         durable: false,
                                         exclusive: false,
                                         autoDelete: false,
                                         arguments: null);

                    // create message and contents
                    string message = "Hello World";
                    var body = Encoding.UTF8.GetBytes(message);

                    // publish message
                    channel.BasicPublish(exchange: "",
                                         routingKey: "hello",
                                         basicProperties: null,
                                         body: body);

                    Console.WriteLine(" [x] Sent {0}", message);
                }
                // wait for user input
                Console.WriteLine("press [enter] to exit.");
                Console.ReadLine();
            }
        }
    }
}
