
/**
 * Write a description of class Heater here.
 *
 * @author (your name)
 * @version (a version number or a date)
 */
public class Heater
{
    // instance variables - replace the example below with your own
    private int temperature;
    private int min;
    private int max;
    private int increment;

    /**
     * Constructor for objects of class Heater
     */
    public Heater(int minimum, int maximum)
    {
        // initialise instance variables
        temperature = 15;
        min = minimum;
        max = maximum;
        increment = 5;
    }

    /**
     * get the temperature 
     */
    
    public int getTemperature()
    {
        // put your code here
        return temperature;
    }
    
    /**
     * set temperature higher
     */
    
    public void warmer()
    {
        if(temperature + increment > max)
        {
            temperature = max;
        } else
        {
           temperature += increment; 
        }
        
    }
    
    /**
     * set temperature lowr
     */
    
    public void cooler()
    {
        if (temperature - increment < min)
        {
            temperature = min;
        } else
        {
            temperature -= increment;
        }
    }
    
    
    /**
     * set increment, if negative converts to positive number
     */
    
    public void setIncrement(int incrementValue)
    {
        if (incrementValue <0) {
            increment = incrementValue * -1;
            System.out.println("The increment cannot be negative! It is set to " + increment); 
        } else {
            increment = incrementValue;
        }
    }
}
