import Foundation

extension CGFloat
{
    public static func mm(_ millimeters: CGFloat) -> CGFloat
    {
        return millimeters * 2.8346456693
    }
    
    public static func `in`(_ inches: CGFloat) -> CGFloat
    {
        return inches * 72
    }
}
