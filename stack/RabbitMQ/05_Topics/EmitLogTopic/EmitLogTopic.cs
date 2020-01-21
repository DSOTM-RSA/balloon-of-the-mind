using System;
using System.Linq;
using System.Text;
using RabbitMQ.Client;

namespace EmitLogTopic
{
    class EmitLogTopics
    {
        static void Main(string[] args)
        {
            // create a factory
            var factory = new ConnectionFactory() { HostName = "localhost" };
            
            // create connection and channel objects
            using(var connection = factory.CreateConnection())
            using(var channel = connection.CreateModel())
            {
                // set exchange type
                channel.ExchangeDeclare(exchange: "topic_logs",
                                        type: "topic");

                // routing key is first argument
                var routingKey = (args.Length > 0) ? args[0] : "anonymous.info";
                
                // message is arguments joined
                var message = (args.Length > 1)
                              ? string.Join(" ", args.Skip(1).ToArray())
                              : "Hello World!";

                // place message in body
                var body = Encoding.UTF8.GetBytes(message);

                channel.BasicPublish(exchange: "topic_logs",
                                     routingKey: routingKey,
                                     basicProperties: null,
                                     body: body);

                Console.WriteLine("[x] Sent '{0}:'{1}'", routingKey, message);
            }
        }
    }
}
