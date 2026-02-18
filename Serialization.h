#ifndef SERIALIZATION_H
#define SERIALIZATION_H

//cereal libraries
#include <cereal/types/string.hpp>
#include <cereal/types/vector.hpp>
#include <cereal/types/list.hpp>
#include <cereal/types/memory.hpp>
#include <cereal/archives/binary.hpp>

//std library
#include <vector>
#include <fstream>
#include <string>
#include <filesystem>
#include <memory>

//Q
#include <QObject>
#include <QList>
#include <QString>
#include <QVector3D>
#include <QSharedPointer>


//qt serialization
namespace cereal
{
    //QString
    template<class Archive>
    void save(Archive& archive, const QString& str)
    {
        std::string s = str.toStdString();
        archive(s);
    }

    template<class Archive>
    void load(Archive& archive, QString& str)
    {
        std::string s;
        archive(s);
        str = QString::fromStdString(s);
    }


    //QVector3D
    template<class Archive>
    void save(Archive& archive, const QVector3D& vector)
    {
        float x = vector.x();
        float y = vector.y();
        float z = vector.z();
        archive(x);
        archive(y);
        archive(z);
    }

    template<class Archive>
    void load(Archive& archive, QVector3D& vector)
    {
        float x, y, z;
        archive(x);
        archive(y);
        archive(z);

        vector = QVector3D(x, y, z);
    }

    //QVector
    /*template<class Archive, typename T>
    void save(Archive& archive, const QVector<T>& vector)
    {
        std::vector<T> v(vector.begin(), vector.end());
        archive(v);
    }

    template<class Archive, typename T>
    void load(Archive& archive, QVector<T>& vector)
    {
        std::vector<T> v;
        archive(v);
        vector = QVector<T>(v.begin(), v.end());
    }*/

    //QList and QVector -> Q treats them as same for some reason
    template<class Archive, typename T>
    void save(Archive& archive, const QList<T>& list)
    {
        std::list<T> l(list.constBegin(), list.constEnd());
        archive(l);
    }

    template<class Archive, typename T>
    void load(Archive& archive, QList<T>& list)
    {
        std::list<T> l;
        archive(l);
        list = QList<T>(l.begin(), l.end());
    }

    //QSharedPtr
    template<class Archive, typename T>
    void save(Archive& archive, const QSharedPointer<T>& ptr)
    {
        bool has = static_cast<bool>(ptr);
        archive(has);
        if (has)
            archive(*ptr);
    }

    template<class Archive, typename T>
    void load(Archive& archive, QSharedPointer<T>& ptr)
    {
        bool has = false;
        archive(has);

        if (!has) { ptr.clear(); return; }

        ptr.reset(new T());   // requires default constructor
        archive(*ptr);
    }
}

#endif // SERIALIZATION_H
